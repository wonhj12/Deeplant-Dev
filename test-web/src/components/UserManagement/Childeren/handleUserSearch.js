const handleUserSearch = (event, allUsers, setSearchedUsers) => {
  const value = event.target.value;
  if (value) {
    const keyword = value.toLowerCase();
    if (!allUsers || allUsers.length === 0) {
      return; // Return early if allUsers is empty or not yet initialized
    }
    if (keyword === '') {
      setSearchedUsers([]); // Show no users if the search field is empty
    } else {
      const results = allUsers.filter(
        (user) =>
          (user.name && user.name.toLowerCase().includes(keyword)) ||
          (user.userId && user.userId.toLowerCase().includes(keyword)) ||
          (user.type && user.type.toLowerCase().includes(keyword)) ||
          (user.company && user.company.toLowerCase().includes(keyword)) ||
          (user.createdAt && user.createdAt.toLowerCase().includes(keyword))
      );
      setSearchedUsers(results);
    }
  }
};

export default handleUserSearch;
