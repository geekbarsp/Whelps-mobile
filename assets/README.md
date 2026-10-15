# Assets

Pet photographs are bundled demo images fetched from Unsplash image URLs. They are illustrative sample listings, not actual animals offered for adoption.

- Milo: https://images.unsplash.com/photo-1552053831-71594a27632d
- Luna: https://images.unsplash.com/photo-1573865526739-10659fec78a5
- Buddy: https://images.unsplash.com/photo-1587300003388-59208cc962cb
- Cleo: https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba

Nunito Sans is bundled from the Google Fonts repository. Its SIL Open Font License is included in `fonts/OFL.txt`.

The initial implementation used provisional branding. The in-app wordmark and palette now follow the supplied Canva reference (see below). Platform launcher icons remain provisional and are reproducibly drawn by `tools/generate-icons.cjs`.
# Canva reference assets

`brand/landing-reference.png` is the user-supplied `Downloads/landingpage.png`; only its wordmark is sampled by the native landing header. `brand/landing-pets.png` was produced with the built-in image-generation tool using the imagegen skill, as a transparent pet cutout adapted from that reference. Final prompt: “Use case: background-extraction. Input image is a reference mobile UI. Create ONLY its hero artwork as a standalone asset: the same friendly golden retriever puppy behind a fluffy tabby-and-white kitten nestled together on a cream fleece blanket. Preserve their poses, expressions, fur colors, warm soft photographic light. Remove ALL lettering, logos, badges, hearts, UI panels, phone frame and background shapes. Isolate the animals and a small foreground blanket on a genuinely transparent background. Square composition, full dog head and kitten visible, clean soft fur edges, no cropping ears or paws. This will be positioned behind native Flutter text on a cream mobile landing page. Output no UI, no text.”

`brand/login-reference.png` is the user-supplied `Downloads/logininterface.png`. The login screen renders only its logo and animal-art regions using native canvas source rectangles; the phone frame and screenshot controls are excluded. Form fields, buttons, text, background waves, password visibility, and loading transitions are native Flutter UI.

`brand/furyou-logo.png`, `brand/whelps-logo.png`, and `brand/reference-cat.jpg` were downloaded from the rendered assets of the user-provided Canva design `DAHU85AwgH0` on September 21, 2026, for the requested mobile adaptation. Logos are preserved as supplied, displayed on cocoa for white-letter contrast. The available FurYou logo is a 150px preview asset; replace with the owner's high-resolution original before store distribution.

`fonts/Fraunces.ttf` is the Fraunces variable font from the Google Fonts repository, distributed under the adjacent `Fraunces-OFL.txt`. It is a mobile editorial interpretation, not a claim to identify the exact Canva typeface.
