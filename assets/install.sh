#

# Installation script for portable Julia with VS Codium
# version 1.0 (C) 2025, Petr Krysl

# Further configuration options for VS Codium:
# {
#    "key": "ctrl+c",
#    "command": "workbench.action.terminal.copySelection",
#    "when": "terminalFocus && terminalProcessSupported && terminalTextSelected"
# },
# {
#    "key": "ctrl+v",
#    "command": "workbench.action.terminal.paste",
#    "when": "terminalFocus && terminalProcessSupported"
# },
# and make sure that this setting is an effect
# {
#     "terminal.integrated.allowChords": false
# }
# To set the window title:
# "window.title": "${activeEditorShort}${separator}${rootName}${separator}${profileName}${separator}focus:[${focusedView}]",

set -o errexit 
set -o nounset

# Select the version of julia to run
MyPortableJuliaMajorVersion=1.11
MyPortableJuliaMinorVersion=.3 # can be used to also select release candidate
MyPortableJulia=julia-$MyPortableJuliaMajorVersion$MyPortableJuliaMinorVersion

echo Julia version: $MyPortableJulia

# Make sure we are in the folder in which the portable Julia is installed.
if [ ! -d "$(pwd)"/assets/$MyPortableJulia ] ; then
    if [ ! -f "$(pwd)"/assets/$MyPortableJulia-win64.zip ] ; then
        echo "Downloading $MyPortableJulia"
        curl https://julialang-s3.julialang.org/bin/winnt/x64/$MyPortableJuliaMajorVersion/$MyPortableJulia-win64.zip --output "$(pwd)"/assets/$MyPortableJulia-win64.zip
    fi
    cd assets
    echo "Unzipping assets/$MyPortableJulia-win64.zip"
    unzip -q "$(pwd)"/$MyPortableJulia-win64.zip
    cd ..
else
    echo "Found $MyPortableJulia"
fi

# Locate the Julia depot in the current folder.
export MyDepot="$(pwd)"/assets/.$MyPortableJulia-depot
if [ ! -d "$MyDepot" ] ; then
    mkdir "$MyDepot"
else
    echo "Found depot $MyDepot"
fi
export JULIA_DEPOT_PATH="$MyDepot"

# We want to find executables in the julia depot
export PATH=$JULIA_DEPOT_PATH/bin:$PATH

# Expand the other zip files
# if [ ! -d assets/gnuplot ] ; then
#     if [ ! -f ./assets/gnuplot.zip ] ; then
#         echo "Downloading gnuplot"
#         curl http://tmacchant33.starfree.jp/gnuplot_files/gp550-20220416-win64-mingw.zip --output ./assets/gnuplot.zip
#     fi
#     echo Installing gnuplot 
#     cd assets
#     unzip -q ./gnuplot.zip
#     cd ..
# fi

# Make sure we can start Julia just by referring to the program name.
export PATH="$(pwd)"/assets/$MyPortableJulia/bin:$PATH

# Make sure we can start gnuplot just by referring to the program name.
# export PATH="$(pwd)"/assets/gnuplot/bin:$PATH

# Add the Git binary
export PATH="$(pwd)"/assets/PortableGit/bin:$PATH

# Download, and instantiate the tutorial packages, in order to bring Julia depot up-to-date 
# if [ ! -d JuliaTutorial ] ; then
#     echo "Activating/instantiating a package"
#     for n in JuliaTutorial
#     do 
#         if [ ! -d $n ] ; then
#             echo "Activating and instantiating $n"
#             git clone https://github.com/PetrKryslUCSD/$n.git
#         fi
#         cd $n
#         julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile(); exit()'
#         cd ..
#     done
# fi

# Make sure the Julia REPL when started activates/instantiates
if [ ! -f "$MyDepot"/config/startup.jl ] ; then
        if [ ! -d "$MyDepot"/config ] ; then
                mkdir "$MyDepot"/config
        fi
        touch "$MyDepot"/config/startup.jl
        # Make sure Revise, JuliaFormatter are present in the default environment
        julia -E 'import Pkg; Pkg.add("Revise")'
        julia -E 'import Pkg; Pkg.add("JuliaFormatter")'
cat<<EOF >> "$MyDepot/config/startup.jl"
using Pkg 
# Disable updating registry on add (still runs on up), as it is slow
Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true
EOF
fi

if [ ! -x "$(pwd)"/assets/VSCodium/VSCodium ] ; then
    VSCodiumVersion="VSCodium.zip"
    if [ ! -d assets/VSCodium ] ; then
        mkdir assets/VSCodium
    fi
    if [ ! -f assets/"$VSCodiumVersion" ] ; then
        echo "Downloading VSCodium "
        curl -LJ "https://github.com/VSCodium/vscodium/releases/download/1.97.2.25045/VSCodium-win32-x64-1.97.2.25045.zip" --output assets/$VSCodiumVersion
    fi
    echo "Expanding $VSCodiumVersion"
    unzip -q "assets/$VSCodiumVersion" -d assets/VSCodium
    # unzip -q "assets/data.zip" -d assets/
    # mv assets/data assets/VSCodium
else
    echo "Found VSCodium"
fi

# Install required extensions
if [ ! -f assets/firsttimedone ] ; then
    if [ ! -d assets/VSCodium/data ] ; then
	mkdir assets/VSCodium/data
    fi
    assets/VSCodium/bin/codium --install-extension alefragnani.Bookmarks --force
    assets/VSCodium/bin/codium --install-extension julialang.language-julia --force
    # assets/VSCodium/bin/codium --install-extension kaiwood.vscode-center-editor-window --force
    # assets/VSCodium/bin/codium --install-extension stkb.rewrap --force
    # assets/VSCodium/bin/codium --install-extension yeannylam.recenter-top-bottom --force
    # assets/VSCodium/bin/codium --install-extension nemesv.copy-file-name --force
    assets/VSCodium/bin/codium --install-extension PKief.material-icon-theme --force
    # assets/VSCodium/bin/codium --install-extension johnpapa.VSCodium-peacock --force
    assets/VSCodium/bin/codium --install-extension chunsen.bracket-select --force
    touch assets/firsttimedone
fi

# Start VS Codium
echo "Starting editor"
assets/VSCodium/VSCodium 
