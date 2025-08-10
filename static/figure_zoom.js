function initFigureZoom() {
  const figures = document.querySelectorAll("figure");

  figures.forEach((f) =>
    f.addEventListener("click", () => {
      const figureName = f.querySelector("figcaption").innerText;
      const figureImage = Array.from(f.querySelectorAll("svg")).concat(
        Array.from(f.querySelectorAll("img")),
      )[0];

      const window_background = document.createElement("div");
      window_background.classList.add("zoom_window_background");

      const zoom_window = document.createElement("div");
      zoom_window.classList.add("zoom_window");

      // Close button
      const zoom_navbar = document.createElement("div");
      zoom_navbar.classList.add("zoom_navbar");
      const zoom_close = document.createElement("div");
      zoom_close.classList.add("zoom_close");
      zoom_close.innerText = "⨯";
      zoom_close.addEventListener("click", () => window_background.remove());
      zoom_navbar.appendChild(zoom_close);
      zoom_window.appendChild(zoom_navbar);

      const image_view_element = document.createElement("div");
      image_view_element.classList.add("zoom_image_view");
      image_view_element.appendChild(figureImage.cloneNode(true));

      zoom_window.appendChild(image_view_element);

      // Legend
      const legend_element = document.createElement("span");
      legend_element.classList.add("zoom_legend");
      legend_element.innerText = figureName;
      zoom_window.appendChild(legend_element);

      window_background.appendChild(zoom_window);

      window_background.addEventListener("click", (e) => {
        if (e.target == window_background) {
          window_background.remove();
        }
      });

      document.body.appendChild(window_background);
    }),
  );
}
