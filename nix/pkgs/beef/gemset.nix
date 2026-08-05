{
  activemodel = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "124gi0hlvkabkl5fzfn90ylj7gbyg22rv5208k8p3hxf5z705k4r";
      type = "gem";
    };
    version = "8.1.3.1";
  };
  activerecord = {
    dependencies = ["activemodel" "activesupport" "timeout"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fs0q1c35k2bh079kj1xbx9pvqx7q2z4k9d32fqgcf29iz1bcbqa";
      type = "gem";
    };
    version = "8.1.3.1";
  };
  activesupport = {
    dependencies = ["base64" "bigdecimal" "concurrent-ruby" "connection_pool" "drb" "i18n" "json" "logger" "minitest" "securerandom" "tzinfo" "uri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xhkhdx8svhaf439y398yixik0snzarnnsy43688p92yy9jqfic5";
      type = "gem";
    };
    version = "8.1.3.1";
  };
  ansi = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0n36cqp65cq259n86wsbyf18iirsjq4ycj0k4x7gncldxb0a17mc";
      type = "gem";
    };
    version = "1.6.0";
  };
  ast = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10yknjyn0728gjn6b5syynvrvrwm66bhssbxq8mkhshxghaiailm";
      type = "gem";
    };
    version = "2.4.3";
  };
  async = {
    dependencies = ["console" "nio4r" "timers"];
    groups = ["ext_dns"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02v87lrqr05034wkhdzhggwgy76bcaq66k0fx2vpy2njfrwymmbb";
      type = "gem";
    };
    version = "1.32.1";
  };
  async-dns = {
    dependencies = ["async" "io-endpoint"];
    groups = ["ext_dns"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nyz9fbbl2kmvfmc30h2qqij11rfbwjxps60xqhml94lild0shh2";
      type = "gem";
    };
    version = "1.4.1";
  };
  base64 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yx9yn47a8lkfcjmigk79fykxvr80r4m1i35q82sxzynpbm7lcr7";
      type = "gem";
    };
    version = "0.3.0";
  };
  bigdecimal = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1g9zi8c4i7g8zz0c3hxrw6mblrjvgn7akys60clb9si7c1k1gljk";
      type = "gem";
    };
    version = "4.1.2";
  };
  concurrent-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qfi2ns3zwkgq616fc127xiqhan7g7m7gqpwriwcr34nds1vxwdj";
      type = "gem";
    };
    version = "1.3.8";
  };
  connection_pool = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02ifws3c4x7b54fv17sm4cca18d2pfw1saxpdji2lbd1f6xgbzrk";
      type = "gem";
    };
    version = "3.0.2";
  };
  console = {
    dependencies = ["fiber-annotation" "fiber-local" "json"];
    groups = ["default" "ext_dns"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mzgyg46jxdyijmg6dkxjv3yqmaixr7mk66094w0cnjrqa3b54w0";
      type = "gem";
    };
    version = "1.37.0";
  };
  daemons = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07cszb0zl8mqmwhc8a2yfg36vi6lbgrp4pa5bvmryrpcz9v6viwg";
      type = "gem";
    };
    version = "1.4.1";
  };
  domain_name = {
    groups = ["default" "ext_notifications"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cyr2xm576gqhqicsyqnhanni47408w2pgvrfi8pd13h2li3nsaz";
      type = "gem";
    };
    version = "0.6.20240107";
  };
  drb = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wrkl7yiix268s2md1h6wh91311w95ikd8fy8m5gx589npyxc00b";
      type = "gem";
    };
    version = "2.2.3";
  };
  em-websocket = {
    dependencies = ["eventmachine" "http_parser.rb"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a66b0kjk6jx7pai9gc7i27zd0a128gy73nmas98gjz6wjyr4spm";
      type = "gem";
    };
    version = "0.5.3";
  };
  erb = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1raacipbb5m0176w05m3n21ip91w7i0cb5zjqhkz2nqgf234kcm9";
      type = "gem";
    };
    version = "6.0.6";
  };
  erubis = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fj827xqjs91yqsydf0zmfyw9p4l2jz5yikg3mppz6d7fi8kyrb3";
      type = "gem";
    };
    version = "2.7.0";
  };
  espeak-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a8lf592zakxmdsn9czv8jxd4a17mm1gnpcn735wd8pmdp8817f1";
      type = "gem";
    };
    version = "1.1.0";
  };
  eventmachine = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wh9aqb0skz80fhfn66lbpr4f86ya2z5rx6gm5xlfhd05bj1ch4r";
      type = "gem";
    };
    version = "1.2.7";
  };
  execjs = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wbkbskyaz1vh4yq0zmf39lnm1q79n9yn508q4q8xsv7hh1axq5b";
      type = "gem";
    };
    version = "2.10.1";
  };
  fiber-annotation = {
    groups = ["default" "ext_dns"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00vcmynyvhny8n4p799rrhcx0m033hivy0s1gn30ix8rs7qsvgvs";
      type = "gem";
    };
    version = "0.2.0";
  };
  fiber-local = {
    dependencies = ["fiber-storage"];
    groups = ["default" "ext_dns"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01lz929qf3xa90vra1ai1kh059kf2c8xarfy6xbv1f8g457zk1f8";
      type = "gem";
    };
    version = "1.1.0";
  };
  fiber-storage = {
    groups = ["default" "ext_dns"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qa0j9qjwav9xb0n3isx0rbh0942xrfback392n6vs8bidnmp3pl";
      type = "gem";
    };
    version = "1.0.1";
  };
  http-accept = {
    groups = ["default" "ext_notifications"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09m1facypsdjynfwrcv19xcb1mqg8z6kk31g8r33pfxzh838c9n6";
      type = "gem";
    };
    version = "1.7.0";
  };
  http-cookie = {
    dependencies = ["domain_name"];
    groups = ["default" "ext_notifications"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1aga7z4p0dka4zcqw9i05wa4ab1q7h7cgnj328ldqqfycjz84jxs";
      type = "gem";
    };
    version = "1.1.6";
  };
  "http_parser.rb" = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yh924g697spcv4hfigyxgidhyy6a7b9007rnac57airbcadzs4s";
      type = "gem";
    };
    version = "0.8.1";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dfikmmd9dllirsfq0kjiyxpmlq0afkxm5sslsr97r9g85ifpy80";
      type = "gem";
    };
    version = "1.15.2";
  };
  io-console = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1k0lk3pwadm2myvpg893n8jshmrf2sigrd4ki15lymy7gixaxqyn";
      type = "gem";
    };
    version = "0.8.2";
  };
  io-endpoint = {
    groups = ["default" "ext_dns"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f1kzf4d5qgqgfjh52a8pf3pii5dmav6ib0zq4wmicqnq5kggsiz";
      type = "gem";
    };
    version = "0.17.2";
  };
  irb = {
    dependencies = ["pp" "prism" "rdoc" "reline"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qs8a9vprg7s8krgq4s0pygr91hclqqyz98ik15p0m1sf2h5956y";
      type = "gem";
    };
    version = "1.18.0";
  };
  json = {
    groups = ["default" "ext_dns" "ext_notifications"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0shwgjqbj856mb6m9kgkpy08nhym2gdvc2yaprlimfmky9y3n78z";
      type = "gem";
    };
    version = "2.21.2";
  };
  language_server-protocol = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1w5p8c2145lmqzr25bxh4ikzjm6k8y1k5lriqqdpw9pq730w1wjy";
      type = "gem";
    };
    version = "3.17.0.6";
  };
  lint_roller = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11yc0d84hsnlvx8cpk4cbj6a4dz9pk0r1k29p0n1fz9acddq831c";
      type = "gem";
    };
    version = "1.1.0";
  };
  logger = {
    groups = ["default" "ext_notifications"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00q2zznygpbls8asz5knjvvj2brr3ghmqxgr83xnrdj4rk3xwvhr";
      type = "gem";
    };
    version = "1.7.0";
  };
  maxmind-db = {
    groups = ["geoip"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0llhhk5np19hk66qsz5c14d14hz8pak1bwm7hwkfjzw4569wfr87";
      type = "gem";
    };
    version = "1.4.0";
  };
  mime-types = {
    dependencies = ["logger" "mime-types-data"];
    groups = ["default" "ext_notifications"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mjyxl7c0xzyqdqa8r45hqg7jcw2prp3hkp39mdf223g4hfgdsyw";
      type = "gem";
    };
    version = "3.7.0";
  };
  mime-types-data = {
    groups = ["default" "ext_notifications"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03vkd9g09jnxsp8mdacvjbplrrqfl5l26n50kd4kdn49zghi326d";
      type = "gem";
    };
    version = "3.2026.0701";
  };
  minitest = {
    dependencies = ["drb" "prism"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wfnqyfayx9n9j7x871v2ars4hjhfisi1dl24fa64ylq3mns6ghm";
      type = "gem";
    };
    version = "6.0.6";
  };
  mize = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "105pjjmncf7q724swbygrbsgmh74ni4s2xaclbyjcm7zg64maca0";
      type = "gem";
    };
    version = "0.6.1";
  };
  mojo_magick = {
    groups = ["default" "ext_qrcode"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "164z9mpdrc5mqjib6hr8fn5jh9fsq2jjzcq25mw849y9al53argi";
      type = "gem";
    };
    version = "0.6.8";
  };
  msfrpc-client = {
    dependencies = ["msgpack"];
    groups = ["ext_msf"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07hjr9j39n0hxlh26a69bsyhkgflxv8kwv8d10930njw3vgknq22";
      type = "gem";
    };
    version = "1.1.2";
  };
  msgpack = {
    groups = ["default" "ext_msf"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yry1bcnbl0c5xwg173n5y647596r8ydmsppa01c5l8d6lnw44a4";
      type = "gem";
    };
    version = "1.8.4";
  };
  mustermann = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "163i29mdcr1h0nximk3d51a1fgp7vz3sfasn8p1rjm2d4g3p0qac";
      type = "gem";
    };
    version = "3.1.1";
  };
  net-protocol = {
    dependencies = ["timeout"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a32l4x73hz200cm587bc29q8q9az278syw3x6fkc9d1lv5y0wxa";
      type = "gem";
    };
    version = "0.2.2";
  };
  net-smtp = {
    dependencies = ["net-protocol"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dh7nzjp0fiaqq1jz90nv4nxhc2w359d7c199gmzq965cfps15pd";
      type = "gem";
    };
    version = "0.5.1";
  };
  netrc = {
    groups = ["default" "ext_notifications"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gzfmcywp1da8nzfqsql2zqi648mfnx6qwkig3cv36n9m0yy676y";
      type = "gem";
    };
    version = "0.11.0";
  };
  nio4r = {
    groups = ["default" "ext_dns"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18fwy5yqnvgixq3cn0h63lm8jaxsjjxkmj8rhiv8wpzv9271d43c";
      type = "gem";
    };
    version = "2.7.5";
  };
  otr-activerecord = {
    dependencies = ["activerecord"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ajmx0hy61kjrfk3n0k9bbk0k8d5zv4jjv6lr49idk0irp53knaf";
      type = "gem";
    };
    version = "2.6.0";
  };
  parallel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mlkn1vhh9lr7vljibpgspwsswk7mzm8nw6bbr616c9fbj35hlmk";
      type = "gem";
    };
    version = "2.1.0";
  };
  parseconfig = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14dj8dwwsyjbmgwn1kbla9vnazqyin4gfi4gwpwlgyvha38lf8p5";
      type = "gem";
    };
    version = "1.1.2";
  };
  parser = {
    dependencies = ["ast" "racc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0a4q5h2hcihk79dbr20scgkm56l79qp7fsvfvkxlv8nmapvxg9i1";
      type = "gem";
    };
    version = "3.3.12.0";
  };
  pp = {
    dependencies = ["prettyprint"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0w5mha75hs8gdj75g8vl0sxpyp8rzvwq8a4jcmi4ah8cf370zjyz";
      type = "gem";
    };
    version = "0.6.4";
  };
  prettyprint = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14zicq3plqi217w6xahv7b8f7aj5kpxv1j1w98344ix9h5ay3j9b";
      type = "gem";
    };
    version = "0.2.0";
  };
  prism = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11ggfikcs1lv17nhmhqyyp6z8nq5pkfcj6a904047hljkxm0qlvv";
      type = "gem";
    };
    version = "1.9.0";
  };
  qr4r = {
    dependencies = ["mojo_magick" "rqrcode_core"];
    groups = ["ext_qrcode"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1y4cr2n3ykxc3mcfwnp827fphmhi0x9v7zr0qw6gsdbfa17g829d";
      type = "gem";
    };
    version = "0.6.2";
  };
  racc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0byn0c9nkahsl93y9ln5bysq4j31q8xkf2ws42swighxd4lnjzsa";
      type = "gem";
    };
    version = "1.8.1";
  };
  rack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hhjy9gcp52dzij05gmidqac8g28ski5xm67prwmdqmjfcgqxmsy";
      type = "gem";
    };
    version = "3.2.6";
  };
  rack-protection = {
    dependencies = ["base64" "logger" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b4bamcbpk29i7jvly3i7ayfj69yc1g03gm4s7jgamccvx12hvng";
      type = "gem";
    };
    version = "4.2.1";
  };
  rack-session = {
    dependencies = ["base64" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1s7zcxlmg88a6dam4aqbgk9xkpy6dkdfqmmcszkkliy3q3w38m2r";
      type = "gem";
    };
    version = "2.1.2";
  };
  rainbow = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      type = "gem";
    };
    version = "3.1.1";
  };
  rake = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "009p524zl0p0kfa65nii8wdmaigkmawv9pbvlcffky7islmmp0nb";
      type = "gem";
    };
    version = "13.4.2";
  };
  rbs = {
    dependencies = ["logger" "prism" "tsort"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j4g0wj90kiirgck0li9vxx2yc2jf0n0z74jxlxj7w88npcb23h5";
      type = "gem";
    };
    version = "4.1.2";
  };
  rdoc = {
    dependencies = ["erb" "prism" "rbs" "tsort"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0sf4909q2mr9z0rpygv94z12b0yamg07gz8cba2mi5k3m448rgq3";
      type = "gem";
    };
    version = "8.0.0";
  };
  readline = {
    dependencies = ["reline"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0shxkj3kbwl43rpg490k826ibdcwpxiymhvjnsc85fg2ggqywf31";
      type = "gem";
    };
    version = "0.0.4";
  };
  regexp_parser = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fwfw26a32rps78920nn29shqg2zmqv72i89j1fap41isshida9m";
      type = "gem";
    };
    version = "2.12.0";
  };
  reline = {
    dependencies = ["io-console"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0d8q5c4nh2g9pp758kizh8sfrvngynrjlm0i1zn3cnsnfd4v160i";
      type = "gem";
    };
    version = "0.6.3";
  };
  rest-client = {
    dependencies = ["http-accept" "http-cookie" "mime-types" "netrc"];
    groups = ["default" "ext_notifications"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qs74yzl58agzx9dgjhcpgmzfn61fqkk33k1js2y5yhlvc5l19im";
      type = "gem";
    };
    version = "2.1.0";
  };
  rexml = {
    groups = ["default" "ext_msf"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hninnbvqd2pn40h863lbrn9p11gvdxp928izkag5ysx8b1s5q0r";
      type = "gem";
    };
    version = "3.4.4";
  };
  rqrcode_core = {
    groups = ["default" "ext_qrcode"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06ld6386hbdhy5h0k09axmgn424kavpc8f27k1vjhknjhbf8jjfg";
      type = "gem";
    };
    version = "1.2.0";
  };
  rubocop = {
    dependencies = ["json" "language_server-protocol" "lint_roller" "parallel" "parser" "rainbow" "regexp_parser" "rubocop-ast" "ruby-progressbar" "unicode-display_width"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gwvjfd3zh40dhggh3p99h62b4v8nl5dqgma9pmmz5fdj0f2bvwd";
      type = "gem";
    };
    version = "1.88.2";
  };
  rubocop-ast = {
    dependencies = ["parser" "prism"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nw84xk6vc2ls8sxqvyhxs2agh4l0jrws85d4bi3x0501lq8ijmr";
      type = "gem";
    };
    version = "1.50.0";
  };
  ruby-progressbar = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      type = "gem";
    };
    version = "1.13.0";
  };
  rubyzip = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00nafgqjhwa504xrjv32v0757a2xcvspsia8s7mp4n62nm2yfy8a";
      type = "gem";
    };
    version = "3.4.1";
  };
  rushover = {
    dependencies = ["json" "rest-client"];
    groups = ["ext_notifications"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j6x61drcdfnbvgmkmrc92zw67acpfcz5h1a29sdf884zkwd1444";
      type = "gem";
    };
    version = "0.3.0";
  };
  securerandom = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cd0iriqfsf1z91qg271sm88xjnfd92b832z49p1nd542ka96lfc";
      type = "gem";
    };
    version = "0.4.1";
  };
  sinatra = {
    dependencies = ["logger" "mustermann" "rack" "rack-protection" "rack-session" "tilt"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "103h6wjpcqp3i034hi44za2v365yz7qk9s5df8lmasq43nqvkbmp";
      type = "gem";
    };
    version = "4.2.1";
  };
  slack-notifier = {
    groups = ["ext_notifications"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "001bipchr45sny33nlavqgxca9y1qqxa7xpi7pvjfqiybwzvm6nd";
      type = "gem";
    };
    version = "2.4.0";
  };
  sqlite3 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01i6k25fv3w3f5ph5cix9ipg19ajsy6zrzxdm18ashzrldrjjmq4";
      type = "gem";
    };
    version = "2.9.5";
  };
  sync = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1z9qlq4icyiv3hz1znvsq1wz2ccqjb1zwd6gkvnwg6n50z65d0v6";
      type = "gem";
    };
    version = "0.5.0";
  };
  term-ansicolor = {
    dependencies = ["tins"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00s6acqfkjarc8qfn9dmkqir9r9ngl95mvcar96vjph9plxfq0cc";
      type = "gem";
    };
    version = "1.11.3";
  };
  thin = {
    dependencies = ["daemons" "eventmachine" "logger" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sddrm5n8jfvyqcmfhxrif6jsp1vla4wv9sx9f3c7xbphdjfbgav";
      type = "gem";
    };
    version = "2.0.1";
  };
  tilt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "089pvsdyf8krrhzavqm1lq4yqf79valiklnn290y1qbgf6r2wixs";
      type = "gem";
    };
    version = "2.8.0";
  };
  timeout = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jxcji88mh6xsqz0mfzwnxczpg7cyniph7wpavnavfz7lxl77xbq";
      type = "gem";
    };
    version = "0.6.1";
  };
  timers = {
    groups = ["default" "ext_dns"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rxdq37h6liiljy5r5q1bnynjra8awam11icllbrn896xk5l6bx9";
      type = "gem";
    };
    version = "4.4.0";
  };
  tins = {
    dependencies = ["bigdecimal" "irb" "mize" "readline" "sync"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vml57h2fw7c97cpchk67jbychsmyzmf9bfjmdilpzdqra0wzrjs";
      type = "gem";
    };
    version = "1.56.0";
  };
  tsort = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17q8h020dw73wjmql50lqw5ddsngg67jfw8ncjv476l5ys9sfl4n";
      type = "gem";
    };
    version = "0.2.0";
  };
  tzinfo = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16w2g84dzaf3z13gxyzlzbf748kylk5bdgg3n1ipvkvvqy685bwd";
      type = "gem";
    };
    version = "2.0.6";
  };
  uglifier = {
    dependencies = ["execjs"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1apmqsad2y1avffh79f4lfysfppz94fvpyi7lkkj3z8bn60jpm3m";
      type = "gem";
    };
    version = "4.2.1";
  };
  unicode-display_width = {
    dependencies = ["unicode-emoji"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hiwhnqpq271xqari6mg996fgjps42sffm9cpk6ljn8sd2srdp8c";
      type = "gem";
    };
    version = "3.2.0";
  };
  unicode-emoji = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03zqn207zypycbz5m9mn7ym763wgpk7hcqbkpx02wrbm1wank7ji";
      type = "gem";
    };
    version = "4.2.0";
  };
  uri = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ijpbj7mdrq7rhpq2kb51yykhrs2s54wfs6sm9z3icgz4y6sb7rp";
      type = "gem";
    };
    version = "1.1.1";
  };
  webrick = {
    groups = ["default" "ext_msf"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ca1hr2rxrfw7s613rp4r4bxb454i3ylzniv9b9gxpklqigs3d5y";
      type = "gem";
    };
    version = "1.9.2";
  };
  xmlrpc = {
    dependencies = ["rexml" "webrick"];
    groups = ["ext_msf"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hjlvq952c80khrj084a3csawrwlshd1v3n8abv5hbpqry6y18jk";
      type = "gem";
    };
    version = "0.3.4";
  };
}
