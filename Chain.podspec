Pod::Spec.new do |s|
  s.name     = "Chain"
  s.version  = "2.0.2"
  s.summary  = "The Official iOS SDK for Chain's Bitcoin API"
  s.homepage = "https://chain.com"
  s.license  = 'MIT'
  s.author   = {"Ryan R. Smith" => "ryan@chain.com"}
  s.social_media_url = 'https://twitter.com/chain'
  s.source   = {:git => "https://github.com/chain-engineering/chain-ios.git", :tag => s.version.to_s }

  s.source_files = 'Chain'
  s.resources = 'Chain/ChainCertificate.der'
  s.public_header_files = 'Chain/Chain.h'

  s.ios.frameworks     = %w{Foundation Security CFNetwork   }
  s.osx.frameworks     = %w{Foundation Security CoreServices}
  s.libraries          = "icucore"

  s.dependency 'CoreBitcoin', "~>0.5.0"

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true
end
