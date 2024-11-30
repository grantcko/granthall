// Album Filter System

export function initializeAlbumFilter() {
  const buttons = document.querySelectorAll('.album-button');
  const videoItems = document.querySelectorAll('.video-item');


  // Initially show only featured videos
  videoItems.forEach(item => {
    if (!item.classList.contains('featured')) {
      item.classList.remove('active');
    }
  });

  // Handle album filter button clicks
  buttons.forEach(button => {
    button.addEventListener('click', () => {
      // If clicking active button, show all videos
      if (button.classList.contains('active')) {
        console.log('removing active');
        button.classList.remove('active');
        videoItems.forEach(item => {
          item.classList.add('active');
        });
        return;
      }

      // Otherwise, filter videos by album
      const albumId = button.dataset.albumId;
      console.log(albumId);
      buttons.forEach(button => {
        button.classList.remove('active');
      });
      button.classList.add('active');

      videoItems.forEach(item => {
        if (!item.classList.contains(albumId)) {
          item.classList.remove('active');
        }
        if (item.classList.contains(albumId)) {
          item.classList.add('active');
        }
      });
    });
  });
}
