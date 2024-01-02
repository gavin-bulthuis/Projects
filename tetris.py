#Implemented Option 1 and 2
import turtle, random

SCALE = 32 #Controls how many pixels wide each grid square is

class Game:
    '''
    Purpose: An object of this class represents the movement of the game.
    Instance Variables: The creation of the occupied list and the creation of the block
    Methods: Gameloop does the movement of the blocks straight down, move left moves the block left, move right moves the block right. '''
    def __init__(self):
        #Setup window size based on SCALE value.
        turtle.setup(SCALE*12+20, SCALE*22+20)

        #Bottom left corner of screen is (-1.5,-1.5)
        #Top right corner is (10.5, 20.5)
        turtle.setworldcoordinates(-1.5, -1.5, 10.5, 20.5)
        cv = turtle.getcanvas()
        cv.adjustScrolls()

        #Ensure turtle is running as fast as possible
        turtle.hideturtle()
        turtle.delay(0)
        turtle.speed(0)
        turtle.tracer(0, 0)

        #Draw rectangular play area, height 20, width 10
        turtle.bgcolor('black')
        turtle.pencolor('white')
        turtle.penup()
        turtle.setpos(-0.525, -0.525)
        turtle.pendown()
        for i in range(2):
            turtle.forward(10.05)
            turtle.left(90)
            turtle.forward(20.05)
            turtle.left(90)


             
        self.active = Block()
        turtle.ontimer(self.gameloop, 300)
        turtle.onkeypress(self.move_left, 'Left')
        turtle.onkeypress(self.move_right, 'Right')
        self.occupied = []
        for i in range(23):
            self.occupied.append([False] * 10)
        #These three lines must always be at the BOTTOM of __init__
        turtle.update()
        turtle.listen()
        turtle.mainloop()
        

       


    def gameloop(self):
        if self.active.valid(0,-1,self.occupied):
            self.active.move(0,-1)
            turtle.update()
        else:
            for obj in self.active.squares:
                x = obj.xcor()
                y = obj.ycor()
                self.occupied[y][x] = True
            self.active = Block()
            turtle.update()
        
       

                

        turtle.ontimer(self.gameloop, 300) 

    def move_left(self):
        if self.active.valid(0,0,self.occupied):
            self.active.move(-1, 0)
            turtle.update()


    def move_right(self):
        if self.active.valid(0,0,self.occupied):
            self.active.move(1,0)
            turtle.update()
      

class Square(turtle.Turtle):
    '''
    Purpose: To create a square and put it into a certain location on the grid.
    Instance Variables: None, just telling the turtle to create a block
    Methods: An initializer that creates the block and sends it to a spot on the grid. '''
    def __init__(self,x,y,color):
        turtle.Turtle.__init__(self)
        self.shape('square')
        self.shapesize(SCALE/20)
        self.speed(0)
        self.fillcolor(color)
        self.pencolor('gray')
        self.penup()
        self.goto(x,y)

class Block:
    '''
    Purpose: To create squares and move them to valid locations.
    Instance Variables: A list of squares
    Methods: Initializer that creates squares in the squares list, a method that moves the block to given coordinates, a method that checks if the block can be moved to a certain location. '''
    def __init__(self):
        self.squares = []
        Block1 = []
        Block1.append(Square(3,22,'blue'))
        Block1.append(Square(3,23,'blue'))
        Block1.append(Square(4,22,'blue'))
        Block1.append(Square(5,22,'blue'))
        Block2 = []
        Block2.append(Square(3,22,'orange'))
        Block2.append(Square(4,22,'orange'))
        Block2.append(Square(5,22,'orange'))
        Block2.append(Square(5,23,'orange'))
        Block3 = []
        Block3.append(Square(3,22,'yellow'))
        Block3.append(Square(3,23,'yellow'))
        Block3.append(Square(4,22,'yellow'))
        Block3.append(Square(4,23,'yellow'))
        Block4 = []
        Block4.append(Square(3,22,'green'))
        Block4.append(Square(4,22,'green'))
        Block4.append(Square(4,23,'green'))
        Block4.append(Square(5,23,'green'))
        Block5 = []
        Block5.append(Square(3,22,'purple'))
        Block5.append(Square(4,22,'purple'))
        Block5.append(Square(5,22,'purple'))
        Block5.append(Square(4,23,'purple'))
        Block6 = []
        Block6.append(Square(3,23,'red'))
        Block6.append(Square(4,22,'red'))
        Block6.append(Square(4,23,'red'))
        Block6.append(Square(5,22,'red'))
        Block7 = []
        Block7.append(Square(3,22,'cyan'))
        Block7.append(Square(4,22,'cyan'))
        Block7.append(Square(5,22,'cyan'))
        Block7.append(Square(6,22,'cyan'))
        Blocks = []
        Blocks.append(Block1)
        Blocks.append(Block2)
        Blocks.append(Block3)
        Blocks.append(Block4)
        Blocks.append(Block5)
        Blocks.append(Block6)
        Blocks.append(Block7)
        random_block = random.choice(Blocks)
        for square in random_block:
            self.squares.append(square)

    

        
       

     
     
    def move(self,dx,dy):
        for obj in self.squares:
            x = obj.xcor()
            y = obj.ycor()
            x = dx + x
            y = dy + y
            obj.goto(x,y)
    def valid(self,dx,dy,occupied):
        for obj in self.squares:
            x = obj.xcor()
            y = obj.ycor()
            x = dx + x
            y = dy + y
            if x < 0 or x > 9 or y < 0 or occupied[y][x] == True:
                return False 
        return True






if __name__ == '__main__':
    Game()