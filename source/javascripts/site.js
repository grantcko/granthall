// Photo Gallery Initialization
document.addEventListener('DOMContentLoaded', function() {
  // Initialize Justified Gallery plugin with configuration
  $("#gallery").justifiedGallery({
    rowHeight: 300,
    margins: 5,
    lastRow: 'justify',
    border: 0,
    captions: false,
    waitThumbnailsLoad: true
  }).on('jg.complete', function() {
    // After gallery loads, initialize PhotoSwipe lightbox
    let lightbox = new PhotoSwipeLightbox({
      gallery: '#gallery',
      children: 'a',
      pswpModule: PhotoSwipe,
      closeOnVerticalDrag: true,
      clickToCloseNonZoomable: false,
      imageClickAction: 'zoom',
      tapAction: 'zoom',
      doubleTapAction: 'zoom',
      bgOpacity: 0.8,
      showHideAnimationType: 'fade'
    });

    lightbox.init();
  });
});

// Album Filter System
document.addEventListener('DOMContentLoaded', function() {
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
});

// Bunny.net Video Player Reset on modal close Handler
document.addEventListener('DOMContentLoaded', function() {
  const videoModals = document.querySelectorAll('.modal');

  videoModals.forEach(modal => {
    modal.addEventListener('hidden.bs.modal', function() {
      const iframe = modal.querySelector('iframe.bunny-video-player');
      if (iframe) {
        const currentSrc = iframe.src;
        iframe.src = ''; // Remove source to force video stop
        // Restore src with autoplay set to false
        setTimeout(() => {
          iframe.src = currentSrc.replace('autoplay=true', 'autoplay=false');
        }, 100);
      }
    });
  });
});

// URL Hash Management for Videos
document.addEventListener('DOMContentLoaded', function() {
  // Open video modal if ID is in URL
  const videoId = window.location.hash.slice(1);
  if (videoId) {
    const targetModal = document.getElementById(`modal-${videoId}`);
    if (targetModal) {
      const modal = new bootstrap.Modal(targetModal);
      modal.show();
    }
  }

  // Update URL when modals open/close
  document.querySelectorAll('.modal').forEach(modal => {
    modal.addEventListener('show.bs.modal', event => {
      const videoId = modal.id.replace('modal-', '');
      window.history.pushState({}, '', `#${videoId}`);
    });

    modal.addEventListener('hidden.bs.modal', () => {
      window.history.pushState({}, '', window.location.pathname);
    });
  });
});
