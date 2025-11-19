const macros = {
  "\\leq": "\\leqslant",
  "\\geq": "\\geqslant",
  "\\Sol": "\\mathcal{S}",
  "\\1": "\\mathbf{1}",
  "\\N": "\\mathbf{N}",
  "\\Z": "\\mathbf{Z}",
  "\\Q": "\\mathbf{Q}",
  "\\R": "\\mathbf{R}",
  "\\C": "\\mathbf{C}",
  "\\U": "\\mathbf{U}",
  "\\F": "\\mathbf{F}",
  "\\P": "\\mathbf{P}",
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
  "\\Def": "\\mathscr{D}",
  "\\Cont": "\\mathscr{C}",
  "\\Diff": "\\mathscr{D}",
  "\\Part": "\\mathscr{P}",
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
  "\\opnorm": "\\left\\lVert#1\\right\\rVert_{\\text{op}}",
  "\\floor": "\\left\\lfloor#1\\right\\rfloor",
  "\\ceil": "\\left\\lceil#1\\right\\rceil",
  "\\card": "\\#",
  "\\prop": "\\mathcal{P}",
  "\\prob": "\\mathbb{P}",
  "\\supp": "\\operatorname{supp}",
  "\\pgcd": "\\operatorname{pgcd}",
  "\\ppcm": "\\operatorname{ppcm}",
  "\\gcd": "\\operatorname{pgcd}",
  "\\lcm": "\\operatorname{ppcm}",
  "\\grp": "\\left\\langle #1 \\right\\rangle",
  "\\arrowlim": "\\ \\xrightarrow[\\;#1\\;]{}\\ ",
  "\\sarrowlim": "\\ \\xrightarrow[\\;#1\\;]{\\text{simplement}}\\ ",
  "\\ev": "\\underset{#1}\\sim",
  "\\textlim": "\\lim\\limits_{#1}",
  "\\dd": "\\mathrm{d}",
  "\\expect": "\\mathbb{E}",
  "\\variance": "\\mathbb{V}",
  "\\Vect": "\\operatorname{Vect}",
  "\\img": "\\operatorname{img}",
  "\\id": "\\operatorname{id}",
  "\\Aut": "\\operatorname{Aut}",
  "\\adh": "\\operatorname{Adh}",
  "\\rang": "\\operatorname{rang}",
  "\\rg": "\\operatorname{rg}",
  "\\mat": "\\operatorname{mat}",
  "\\tr": "\\operatorname{tr}",
  "\\com": "\\operatorname{com}",
  "\\mtx": "\\begin{pmatrix}#1\\end{pmatrix}",
  "\\vmtx": "\\begin{vmatrix}#1\\end{vmatrix}",
  "\\arrmtx": "\\left(\\def\\arraystretch{1.5}\\begin{array}{#1}#2\\end{array}\\right)",
  "\\arrvmtx": "\\left|\\def\\arraystretch{1.5}\\begin{array}{#1}#2\\end{array}\\right|",
  "\\arr": "\\def\\arraystretch{1.5}\\begin{array}{#1}#2\\end{array}",
  "\\transp": "^{\\mkern-1.5mu\\mathsf{T}}",
  "\\tilde": "\\widetilde",
  "\\applic": "\\begin{array}{rcl}#1 & \\longrightarrow & #2 \\\\ #3 & \\longmapsto & #4\\end{array}",
  "\\scalar": "\\left\\langle #1 \\middle\\vert #2 \\right\\rangle",
  "\\infabs": "\\left\\lVert#1\\right\\rVert_{\\infty, #2}",
  "\\where": "\\;|\\;",
  "\\oo": "\\left]#1\\right[",
  "\\oc": "\\left]#1\\right]",
  "\\co": "\\left[#1\\right[",
  "\\cc": "\\left[#1\\right]",
  "\\iset": "\\llbracket #1 \\rrbracket",
  "\\ioo": "\\rrbracket #1 \\llbracket",
  "\\ioc": "\\rrbracket #1 \\rrbracket",
  "\\ico": "\\llbracket #1 \\llbracket",
  "\\icc": "\\llbracket #1 \\rrbracket",
  "\\usim": "\\underset{#1}{\\sim}",
  "\\ueq": "\\underset{#1}{=}",
  "\\oeq": "\\overset{\\text{#1}}{=}",
  "\\defeq": "\\overset{\\text{def}}{=}",
  "\\ugeq": "\\underset{#1}{\\geq}",
  "\\ogeq": "\\overset{\\text{#1}}{\\geq}",
  "\\uleq": "\\underset{#1}{\\leq}",
  "\\oleq": "\\overset{\\text{#1}}{\\leq}",
  "\\dv": "\\frac{\\dd #1}{\\dd #2}",
  "\\dvN": "\\frac{\\dd^{#3} #1}{\\dd {#2}^{#3}}",
  "\\pdv": "\\frac{\\partial #1}{\\partial #2}",
  "\\pdvN": "\\frac{\\partial^{#3} #1}{\\partial {#2}^{#3}}",
  "\\ortho": "^{\\perp}",
  "\\emptyset": "\\varnothing",
  "\\mdot": "\\boldsymbol{\\cdot}",
  "\\hat": "\\widehat",
  "\\sp": "\\operatorname{Sp}",
  "\\diag": "\\operatorname{diag}",
  "\\long": "\\operatorname{long}",
  "\\sembl": "\\overset{\\tiny S}\\sim",
  "\\mangl":"\\angl{\\scriptsize $#1$\\,}",
  "\\sur":"\\text{ sur }",
  "\\if":"&\\text{si }"
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
            macros: macros,
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
