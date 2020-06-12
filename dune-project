(lang dune 2.0)

(package
  (name subtalk)
  (synopsis "Generate well-spaced subtitles from a script")
	(license GPL-3.0-or-later)
	(maintainers "Martin Constantino–Bodin <martin.bodin@ens-lyon.org>")
	(source (github Mbodin/subtalk)))

(explicit_js_mode)

(using menhir 2.0)

