module Truefactor
  module Helper
    def link_to_truefactor
      link_to(truefactor_path) do
        image_tag 'https://truefactor.io/signin.png'        
      end
    end
  end
end
