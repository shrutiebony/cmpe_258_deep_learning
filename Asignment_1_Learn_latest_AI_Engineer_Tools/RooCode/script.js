document.addEventListener('DOMContentLoaded', () => {
    fetch('/api/data')
        .then(response => response.json())
        .then(data => {
            const dataDiv = document.getElementById('data');
            dataDiv.textContent = data.message;
        })
        .catch(error => console.error('Error fetching data:', error));
});