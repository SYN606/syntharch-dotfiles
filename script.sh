

# install required packages 
sudo pacman -S --needed fish eza bat fastfetch expac yay paru ugrep btop hwinfo reflector meld tar wget p7zip xsel starship ttf-firacode-nerd ttf-jetbrains-mono

git clone https://github.com/NvChad/starter ~/.config/nvim

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf


rsync -av .config/ $HOME/.config/
rsync -av .local/ $HOME/.local/

echo "All done. Run neo vim to load config properly."
