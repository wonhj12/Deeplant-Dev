import ApexCharts from 'react-apexcharts';
import React, { useEffect, useState } from 'react';
import CircularProgress from '@mui/material/CircularProgress';
import { statisticProbexptFresh } from '../../../../API/statistic/statisticProbexptFresh';
import calculateBoxPlotStatistics from './calculateBoxPlotStat';

const Taste_FreshMeat = ({ startDate, endDate, animalType, grade }) => {
  const [chartData, setChartData] = useState([]); // Change initial state to null

  const fetchData = async () => {
    try {
      const response = await statisticProbexptFresh(
        startDate,
        endDate,
        animalType,
        grade
      );

      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      const data = await response.json();
      setChartData(data);
    } catch (error) {
      console.error('Error fetching chartData:', error);
    }
  };

  useEffect(() => {
    if (startDate && endDate) {
      fetchData();
    }
  }, [startDate, endDate, animalType, grade]);

  const chartOptions = {
    chart: {
      type: 'boxPlot',
      height: 350,
    },
    title: {
      text: '원육 맛데이터 박스 플롯(Box Plot) 분포',
    },
  };

  // Conditionally render the chart or CircularProgress based on chartData
  return (
    <div>
      {chartData && chartData.bitterness && chartData.bitterness.values ? (
        <ApexCharts
          series={[
            {
              type: 'boxPlot',
              data: [
                {
                  x: '진한맛(bitterness)',
                  y: calculateBoxPlotStatistics(chartData.bitterness.values),
                },
                {
                  x: '후미(richness)',
                  y: calculateBoxPlotStatistics(chartData.richness.values),
                },
                {
                  x: '신맛(sourness)',
                  y: calculateBoxPlotStatistics(chartData.sourness.values),
                },
                {
                  x: '감칠맛(umami)',
                  y: calculateBoxPlotStatistics(chartData.umami.values),
                },
              ],
            },
          ]}
          options={chartOptions}
          type="boxPlot"
          height={350}
        />
      ) : (
        <CircularProgress />
      )}
    </div>
  );
};

export default Taste_FreshMeat;
