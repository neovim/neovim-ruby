expect(Vim).to eq(VIM)
expect(Vim.strwidth("hi")).to eq(2)

expect($curbuf).to be_a(Neovim::Buffer)
expect(Vim::Buffer.current).to eq($curbuf)

expect($curwin).to be_a(Neovim::Window)
expect(Vim::Window.current).to eq($curwin)
