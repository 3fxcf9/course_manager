function initTOC() {
  const headings = document.querySelectorAll("h2, h3, h4, h5, h6");

  let toc_html = '<ol class="toc">';
  let last_heading_level = 2;

  for (heading of headings) {
    // heading.id = heading.innerText.replaceAll(" ", "-").replaceAll("\n", "-");
    console.log(btoa(Math.random()))
    heading.id = btoa(Math.random())

    let link_html = `<a href="#${heading.id}">${heading.innerHTML}</a>`;

    let current_level = parseInt(heading.nodeName.slice(-1));

    if (current_level > last_heading_level) {
      toc_html += `<ol>\n<li>${link_html}`;
    } else if (current_level < last_heading_level) {
      toc_html += `</li></ol>\n<li>${link_html}`;
    } else {
      toc_html += `</li>\n<li>${link_html}`;
    }

    last_heading_level = current_level;
  }

  toc_html += "</ol>";

  const toc_element = document.createElement("nav");
  toc_element.classList.add("toc-wrapper");
  toc_element.innerHTML = toc_html;

  const h1 = document.querySelector("h1");
  if (h1) {
    h1.insertAdjacentElement("afterend", toc_element);
  } else {
    document.body.prepend(toc_element);
  }

  // Highlight current section
  const toc_links = document.querySelectorAll("nav a");

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        const id = entry.target.getAttribute("id");
        const toc_item = document.querySelector(`nav a[href="#${id}"]`);
        if (entry.isIntersecting) {
          toc_links.forEach((link) => link.classList.remove("active"));
          if (toc_item) toc_item.classList.add("active");
        }
      });
    },
    {
      rootMargin: "0px 0px -50% 0px",
      threshold: 0,
    },
  );

  headings.forEach((section) => {
    observer.observe(section);
  });
}
