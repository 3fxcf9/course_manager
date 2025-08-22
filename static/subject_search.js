const input = document.querySelector("input[name=search_query]");
const chapter_elements = document.querySelectorAll(".chapter");

const chapters = Array.from(chapter_elements).map((chap) => {
  return {
    name: chap.querySelector(".chapter-name").innerText,
    desc: chap.dataset.chapterDescription || '',
    keywords: chap.dataset.chapterKeywords || '',
    elem: chap,
  };
});

function matches(chapter, query) {
  return chapter.name.includes(query) || chapter.keywords.includes(query) || chapter.desc.includes(query);
}

input.addEventListener("input", () => {
  let query = input.value;

  chapters.forEach((c) => c.elem.classList.remove("hidden"));
  chapters
    .filter((c) => !matches(c, query))
    .forEach((c) => c.elem.classList.add("hidden"));
});
