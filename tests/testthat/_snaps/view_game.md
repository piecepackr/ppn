# view_game works as expected

    Code
      write_ppn(list(game2), "")
    Output
      ---
      Event: Example Tic-Tac-Toe Game
      Result: 1-0
      ...
      
      
      setup. t@b2
      1. S@b2 1... M@a2 {? (1... M@a1)}
      2. S@c1 2... M@a3
      3. S@a1 3... M@c3
      4. S@b1 {X wins}

---

    Code
      print_screen(game, move, clear = FALSE, color = FALSE)
    Output
      ---
      Event: Example Tic-Tac-Toe Game
      Result: 1-0
      ...
      setup. t@b2
      1. S@b2 1... M@a2 {? (1... M@a1)}
      2. S@c1 2... M@a3
      3. S@a1 3... M@c3
      4. S@b1 {X wins}
      Prev move: 4. S@b1
      
              
        ☾⃝─┰─☾⃝ 
        │ ┃ │ 
        ☾⃝━☀⃝━┥ 
        │ ┃ │ 
        ☀⃝─☀⃝─☀⃝ 
              
              
      

---

    Code
      p$print_help()
    Output
      usage: View game ...
      
      positional arguments:
           subcommands
          a
           append to ppn
          c
           animate game via cat_game()
          e
           edit ppn
          g
           go to move
          h
           help
          l
           list moves
          n
           next move
          p
           previous move
          q
           quit
          r
           render current move via plot_move()

