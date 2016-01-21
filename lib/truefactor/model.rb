module Truefactor
  module Model
    extend ::ActiveSupport::Concern

    module ClassMethods
      def truefactorize
        class_exec do
          send :include, Truefactor::Model::TruefactorizedMethods
          ::Truefactor.model_name = name.classify
        end
      end
    end

    module TruefactorizedMethods
      def truefactor_signatures(challenge, raw = false)
        seed1, seed2 = self.truefactor.split(',')
        unless raw
          stamp = Time.now.to_i / 120
          challenge = "#{challenge}:#{stamp}"
        end
        [to_otp(challenge, seed1), to_otp(challenge, seed2)]
      end

      def valid_truefactor?(challenge, str)
        sig1, sig2 = str.gsub(/\s/,'').split(',')

        real_sig = to_otp(truefactor_signatures(challenge).join)

        sig1 = to_digits(sig1)
        sig2 = to_digits(sig2)

        sig1 = to_otp(sig1 + sig2) if sig2.present?

        real_sig == sig1
      end

      def to_otp(m, secret = false)
        hex =
          if secret
            OpenSSL::HMAC.hexdigest('sha256', secret, m)
          else
            OpenSSL::Digest::SHA256.hexdigest(m)
          end

        code = (hex.to_i(16) % 10**12).to_s

        '0'*(12-code.length) + code
      end

      def to_digits(s)
        s = s.to_s
        if s.length == 8
          s.to_i(32).to_s.rjust(12,'0')
        else
          s
        end
      end
    end
  end
end
