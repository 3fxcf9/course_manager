const macros = {
  "\\leq": "\\leqslant",
  "\\geq": "\\geqslant",
  "\\Sol": "\\mathcal{S}",
  "\\N": "\\mathbf{N}",
  "\\Z": "\\mathbf{Z}",
  "\\Q": "\\mathbf{Q}",
  "\\R": "\\mathbf{R}",
  "\\C": "\\mathbf{C}",
  "\\U": "\\mathbf{U}",
  "\\F": "\\mathbf{F}",
  "\\P": "\\mathcfl{P}",
  "\\K": "\\mathbf{K}",
  "\\L": "\\mathscr{L}",
  "\\B": "\\mathscr{B}",
  "\\D": "\\mathbf{D}",
  "\\M": "\\mathcal{M}",
  "\\E": "\\mathscr{E}",
  "\\GL": "\\mathscr{GL}",
  "\\GLM": "\\mathrm{GL}",
  "\\CM": "\\mathscr{CM}",
  "\\Func": "\\mathcal{F}",
  "\\Cont": "\\mathcal{C}",
  "\\Diff": "\\mathcal{D}",
  "\\Part": "\\mathcal{P}",
  "\\bar": "\\overline",
  "\\ubar": "\\underline",
  "\\Re": "\\mathscr{R\\!e}",
  "\\Im": "\\mathscr{I\\!\\!m}",
  "\\ch": "\\operatorname{ch}",
  "\\sh": "\\operatorname{sh}",
  "\\th": "\\operatorname{th}",
  "\\set": "\\{\\,#1\\,\\}",
  "\\cgm": "\\equiv #1 \\left[#2\\right]",
  "\\ncgm": "\\not\\equiv #1 \\left[#2\\right]",
  "\\vv": "\\overrightarrow{#1}",
  "\\abs": "\\left\\lvert#1\\right\\rvert",
  "\\norm": "\\left\\lVert#1\\right\\rVert",
  "\\card": "\\#",
  "\\prop": "\\mathcal{P}",
  "\\prob": "\\mathbb{P}",
  "\\supp": "\\operatorname{supp}",
  "\\pgcd": "\\operatorname{pgcd}",
  "\\ppcm": "\\operatorname{ppcm}",
  "\\gcd": "\\operatorname{pgcd}",
  "\\lcm": "\\operatorname{ppcm}",
  "\\grp": "\\left\\langle #1 \\right\\rangle",
  "\\arrowlim": "\\ \\xrightarrow[\\;#1 \\to #2\\;]{}\\ ",
  "\\textlim": "\\lim\\limits_{#1}",
  "\\dd": "\\mathrm{d}",
  "\\expect": "\\mathbb{E}",
  "\\variance": "\\mathbb{V}",
  "\\Vect": "\\operatorname{Vect}",
  "\\img": "\\operatorname{img}",
  "\\id": "\\operatorname{id}",
  "\\Aut": "\\operatorname{Aut}",
  "\\rang": "\\operatorname{rang}",
  "\\rg": "\\operatorname{rg}",
  "\\mat": "\\operatorname{mat}",
  "\\tr": "\\operatorname{tr}",
  "\\mtx": "\\begin{pmatrix}#1\\end{pmatrix}",
  "\\transp": "^{\\mkern-1.5mu\\mathsf{T}}",
  "\\tilde": "\\widetilde",
  "\\applic": "\\begin{array}{rcl}#1 & \\longrightarrow & #2 \\\\ #3 & \\longmapsto & #4\\end{array}",
  "\\scalar": "\\left\\langle #1 \\middle\\vert #2 \\right\\rangle",
  "\\infabs": "\\left\\lVert#1\\right\\rVert_{\\infty, #2}",
  "\\oo": "\\left]#1\\right[",
  "\\oc": "\\left]#1\\right]",
  "\\co": "\\left[#1\\right[",
  "\\cc": "\\left[#1\\right]",
  "\\iset": "\\llbracket #1 \\rrbracket",
  "\\ioo": "\\rrbracket #1 \\llbracket",
  "\\ioc": "\\rrbracket #1 \\rrbracket",
  "\\ico": "\\llbracket #1 \\llbracket",
  "\\icc": "\\llbracket #1 \\rrbracket",
  "\\where": "\\;\\middle\\vert\\;",
  "\\usim": "\\underset{#1}{\\sim}",
  "\\ortho": "^{\\perp}",
  "\\emptyset": "\\varnothing",
  "\\mdot": "\\boldsymbol{\\cdot}",
  "\\hat": "\\widehat"
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
