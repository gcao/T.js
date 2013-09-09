T.def 'main', ->
  [ '.gameviewer.size-21'
    T('banner'     ).process()
    T('board'      ).process()
    T('toolbar'    ).process()
    T('point-label').process()
    T('right-panel').process()
  ]

T.def 'banner', ->
  [ '.banner'
    [ '.banner-overlay' ]
    [ '.banner-left'
      T('language-switcher').process()
      '&nbsp;&nbsp;'
      t('whose_turn')
      "&nbsp;"
      [ 'img.next-player', src: 'images/default.gif' ]
    ]
    T('move-number').process()
    T('resign'     ).process()
    [ '.banner-overlay'
      T('banner-prisoners').process()
      T('window-opener'   ).process()
    ]
  ]

T.def 'language-switcher', ->
  [
    [ 'a.localization'
      href: 'javascript: void(jsGameViewer.1.changeLocale("zh_cn"))'
      '中文'
    ]
    ' | '
    [ 'a.localization'
      href: 'javascript: void(jsGameViewer.1.changeLocale("en_us"))'
      'EN'
    ]
  ]

T.def 'move-number', ->
  [ '.button.move-number-outer'
    [ 'a.thickbox'
      href: '#TB_inline?test=0&width=250&height=56&inlineId=1_goTo&focus=1_goToInput&modal=true&test1=0'
      title: "#{t('jump_to_xx')} [Alt Shift G]"
      t('move_number_before')
      '&nbsp;'
      [ 'span.control-text.move-number', 0 ]
      '&nbsp;'
      t('move_number_after')
    ]
  ]

T.def 'resign', ->
  [ '.resign'
    [ 'span.button'
      [ 'a'
        href: 'javascript: void(jsGameViewer.1.resign())'
        t('resign')
      ]
    ]
  ]

T.def 'banner-prisoners', ->
  [ '.prisoners-outer'
    T('banner-prisoner', 'black')
    T('banner-prisoner', 'white')
  ]

T.def 'banner-prisoner', (color) ->
  [ ".#{color}"
    [ 'span.button'
      [ 'a'
        href: 'javascript: void(0)'
        [ 'img.prisoners'
          src: "images/15/#{color}_dead.gif"
          '&nbsp;'
          [ "span.control-text.#{color}_PRISONERS", 0 ]
        ]
      ]
    ]
  ]

T.def 'window-opener', ->
  [ '.open-window-outer'
    [ 'a'
      title: "#{t('open_in_new_window')} [Alt Shift W]"
      href: 'javascript: void(jsGameViewer.1.openInWindow())'
      [ 'img.sprite-newwindow', src: 'images/default.gif' ]
    ]
  ]

T.def 'board', ->
  [ '.board-outer.sprite-21-board'
    [ '.board'
      [ '.board-overlay.points' ]
      [ '.board-overlay.marks' ]
      [ '.board-overlay.branches' ]
      [ '.sprite-21-markmove.move-marks' ]
      [ '.board-overlay.prisoners' ]
      [ '.board-overlay.fascade'
        [ 'img.sprite-21-blankboard', src: 'images/default.gif' ]
      ]
    ]
  ]

T.def 'toolbar', ->
  [ '.toolbar'
    [ '.tb-item.refresh'
      [ 'a.toggle-opacity'
        href: "javascript: void(jsGameViewer.1.refresh(true))"
        title: "#{t('refresh')} [Alt Shift R]"
        [ 'img.sprite-refresh', src: 'images/default.gif' ]
      ]
    ]
    [ '.tb-item.toggle-number'
      [ 'a.toggle-opacity'
        href: "javascript: void(jsGameViewer.1.toggleNumber())"
        title: "#{t('refresh')} [Alt Shift R]"
        [ 'img.sprite-toggle-number', src: 'images/shownumber.gif' ]
      ]
    ]
  ]

T.def 'point-label', ->
  [ '.point-label' ]

T.def 'right-panel', ->
  [ '.right-pane'
    [ '.info' ]
    [ '.comment' ]
  ]

$('#container').html(T('main').render())

