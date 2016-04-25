#### Editing the theme

* Install `nvm` (https://github.com/creationix/nvm)

* Run `nvm i` from the directory containing `.nvmrc`

* Run `npm i` from the directory containing `gulpfile.js`. It's the same directory as the one that contains `.nvmrc` in this case.

* Install `gulp`, `gulp-filter`, and `gulp-sass` with `npm i -g gulp gulp-filter gulp-sass`

* Edit the sass/*.scss files

* Regenerate the .css files by executing `gulp` from the directory that contains `gulpfile.js`

--

#### Editing the images in the `assets` folder

* Open the `assets.svg` file in inkscape. Each object in the .svg file corresponds to an image in the `assets` folder.

* Find the object you want to edit and make your changes. Important: Don't change the obejct id.

* Save `assets.svg` and delete the images corresponding to the edited .svg objects from the `assets` folder (or just delete everything in the `assets` folder).

* Execute `render-assets.sh` (the script needs inkscape and optipng) to render the png assets.

