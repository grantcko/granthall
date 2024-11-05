// Scroll animation function that reveals elements as they come into view
function scrollTrigger(selector) {
  // Get all elements matching the selector and convert to array
  let els = document.querySelectorAll(selector);
  els = Array.from(els);

  // Create an Intersection Observer to watch when elements become visible
  let observer = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      // When element becomes visible
      if (entry.isIntersecting) {
        entry.target.classList.add('active'); // Add 'active' class
        observer.unobserve(entry.target);     // Stop watching this element
      }
    });
  }, {
    root: null,           // Use viewport as root
    rootMargin: '0px',    // No margin
    threshold: 0.1        // Trigger when 10% of element is visible
  });

  // Start observing each element
  els.forEach(el => {
    observer.observe(el);
  });
}

// Initialize scroll animations when page loads
document.addEventListener('DOMContentLoaded', function() {
  scrollTrigger('.scroll-reveal');
});

// Video Modal Handler - Manages video popups
document.addEventListener('DOMContentLoaded', function() {
  const videoModal = document.getElementById('videoModal');
  if (!videoModal) return;

  // Check URL for video ID on page load (for direct links to videos)
  const videoId = window.location.hash.slice(1);
  if (videoId) openVideoModal(videoId);

  // When modal opens
  videoModal.addEventListener('show.bs.modal', event => {
    const button = event.relatedTarget;
    const videoId = button.dataset.videoId;
    const videoTitle = button.dataset.videoTitle;

    // Update modal content and URL
    updateModalContent(videoModal, videoId, videoTitle);
    window.history.pushState({}, '', `#${videoId}`);
  });

  // When modal closes
  videoModal.addEventListener('hidden.bs.modal', () => {
    // Clear URL hash and video source
    window.history.pushState({}, '', window.location.pathname);
    videoModal.querySelector('iframe').src = '';
  });
});

// Helper function to update modal content
function updateModalContent(modal, videoId, videoTitle) {
  modal.querySelector('.modal-title').textContent = videoTitle;
  modal.querySelector('iframe').src = getVimeoEmbedUrl(videoId);
}

// Helper function to open video modal programmatically
function openVideoModal(videoId) {
  const button = document.querySelector(`[data-video-id="${videoId}"]`);
  if (!button) return;

  const modal = new bootstrap.Modal(videoModal);
  updateModalContent(videoModal, videoId, button.dataset.videoTitle);
  modal.show();
}

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

// Video Modal and Focus Handler
document.addEventListener('DOMContentLoaded', function() {
  const videoModals = document.querySelectorAll('.modal');

  videoModals.forEach(modal => {
    const iframe = modal.querySelector('iframe.bunny-video-player');

    modal.addEventListener('hidden.bs.modal', function() {
      if (iframe) {
        iframe.src = ''; // Stop video
        iframe.setAttribute('tabindex', '-1'); // Make non-focusable
      }
    });

    modal.addEventListener('show.bs.modal', function() {
      if (iframe && !iframe.src) {
        iframe.src = `https://iframe.mediadelivery.net/embed/${modal.id.replace('modal-', '')}?autoplay=true&customCSS=true`;
        iframe.setAttribute('tabindex', '0'); // Make focusable
      }
    });
  });
});
