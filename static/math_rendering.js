const macros = {
  "\\leq": "\\leqslant",
  "\\geq": "\\geqslant",
  "\\Sol": "\\mathcal{S}",
  "\\N": "\\mathbb{N}",
  "\\Z": "\\mathbb{Z}",
  "\\Q": "\\mathbb{Q}",
  "\\R": "\\mathbb{R}",
  "\\C": "\\mathbb{C}",
  "\\U": "\\mathbb{U}",
  "\\F": "\\mathbb{F}",
  "\\P": "\\mathcal{P}",
  "\\K": "\\mathbb{K}",
  "\\L": "\\mathscr{L}",
  "\\B": "\\mathscr{B}",
  "\\M": "\\mathcal{M}",
  "\\GL": "\\mathscr{GL}",
  "\\GLM": "\\mathrm{GL}",
  "\\Func": "\\mathcal{F}",
  "\\Cont": "\\mathcal{C}",
  "\\Diff": "\\mathcal{D}",
  "\\conj": "\\overline",
  "\\Re": "\\mathscr{R\\!e}",
  "\\Im": "\\mathscr{I\\!\\!m}",
  "\\acos": "\\operatorname{Arccos}",
  "\\asin": "\\operatorname{Arcsin}",
  "\\atan": "\\operatorname{Arctan}",
  "\\ch": "\\operatorname{ch}",
  "\\sh": "\\operatorname{sh}",
  "\\th": "\\operatorname{th}",
  "\\set": "\\{\\,#1\\,\\}",
  "\\cgm": "\\equiv #1 \\left[#2\\right]",
  "\\ncgm": "\\not\\equiv #1 \\left[#2\\right]",
  "\\lient": "[\\![",
  "\\rient": "]\\!]",
  "\\iset": "\\lient #1 \\rient",
  "\\vv": "\\overrightarrow{#1}",
  "\\norm": "\\left\\lVert#1\\right\\rVert",
  "\\prop": "\\mathcal{P}",
  "\\mathquote": "\\frquote{\\text{#1}}",
  "\\arrowlim": "\\ \\xrightarrow[\\;#1 \\to #2\\;]{}\\ ",
  "\\textlim": "\\lim\\limits_{#1}",
  "\\eps": "\\varepsilon",
  "\\ph": "\\varphi",
  "\\lbda": "\\lambda",
  "\\dd": "\\mathrm{d}",
  "\\prob": "\\mathbb{P}",
  "\\expect": "\\mathbb{E}",
  "\\variance": "\\mathbb{V}",
  "\\Vect": "\\operatorname{Vect}",
  "\\Ker": "\\operatorname{Ker}",
  "\\Img": "\\operatorname{Im}",
  "\\Id": "\\operatorname{Id}",
  "\\rg": "\\operatorname{rg}",
  "\\mat": "\\operatorname{mat}",
  "\\tr": "\\operatorname{tr}",
  "\\mtx": "\\begin{pmatrix}#1\\end{pmatrix}",
  "\\transp": "^{\\mkern-1.5mu\\mathsf{T}}",
  "\\tilde": "\\widetilde",
  "\\applic":
    "\\begin{array}{rcl}#1 & \\longrightarrow & #2 \\\\ #3 & \\longmapsto & #4\\end{array}",
  // "\\transp": "^{\\top}",
};

// document.addEventListener("DOMContentLoaded", function () {});
function renderMath() {
  document
    .querySelectorAll("code.math-inline, code.math-display")
    .forEach((element) => {
      let math = element.textContent;
      // Create a new element for rendering
      const renderElement = document.createElement(
        element.classList.contains("math-display") ? "div" : "span",
      );
      // Replace the code element with the new element
      element.parentNode.replaceChild(renderElement, element);
      try {
        katex.render(math, renderElement, {
          displayMode: element.classList.contains("math-display"),
          throwOnError: false,
          macros: macros,
        });
      } catch (e) {
        console.error("KaTeX rendering error:", e);
      }
    });

  // Render math in svg figures
  const svgs = document.querySelectorAll("svg");

  svgs.forEach((svg) => {
    const texts = svg.querySelectorAll("text");

    texts.forEach((text) => {
      const raw = text.textContent.trim();

      // Check if it looks like math (you can tweak this logic)
      if (raw.startsWith("$") && raw.endsWith("$")) {
        const expr = raw.slice(1, -1); // remove $...$
        const span = document.createElement("span");

        try {
          katex.render(expr, span, {
            throwOnError: false,
          });

          // Replace SVG <text> with foreignObject to embed HTML inside SVG
          const bbox = text.getBBox();

          const foreign = document.createElementNS(
            "http://www.w3.org/2000/svg",
            "foreignObject",
          );
          foreign.setAttribute("x", bbox.x);
          foreign.setAttribute("y", bbox.y);
          foreign.setAttribute("width", bbox.width); // TODO: Clean latex size in svg
          foreign.setAttribute("height", bbox.height * 1.2);
          foreign.setAttribute("font-size", text.getAttribute("font-size"));
          foreign.appendChild(span);

          text.replaceWith(foreign);
        } catch (e) {
          console.warn("KaTeX failed on", raw, e);
        }
      }
    });
  });
}
