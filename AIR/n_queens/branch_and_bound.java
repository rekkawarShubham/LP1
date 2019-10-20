import java.util.Scanner;

public class branch_and_bound 
{
    int N;

    void printSolution(int board[][])
    {
        for (int i = 0; i < N; i++)
        {
            for (int j = 0; j < N; j++)
                System.out.print(board[i][j]+"\t");
            System.out.println();
        }
    }

    boolean isSafe(int row, int col, int slashCode[][],
                int backslashCode[][], boolean rowLookup[],
                boolean slashCodeLookup[], boolean backslashCodeLookup[] )
    {
        if (slashCodeLookup[slashCode[row][col]] ||
                backslashCodeLookup[backslashCode[row][col]] ||
                rowLookup[row])
            return false;

        return true;
    }


    boolean solveNQueensUtil(int board[][], int col,
                          int slashCode[][], int backslashCode[][], boolean rowLookup[],
                          boolean slashCodeLookup[], boolean backslashCodeLookup[] )
    {
    /* base case: If all queens are placed
    then return true */
        if (col >= N)
            return true;

    /* Consider this column and try placing
       this queen in all rows one by one */
        for (int i = 0; i < N; i++)
        {
        /* Check if queen can be placed on
           board[i][col] */
            if ( isSafe(i, col, slashCode, backslashCode, rowLookup,
                    slashCodeLookup, backslashCodeLookup) )
            {
                /* Place this queen in board[i][col] */
                board[i][col] = 1;
                rowLookup[i] = true;
                slashCodeLookup[slashCode[i][col]] = true;
                backslashCodeLookup[backslashCode[i][col]] = true;

                /* recur to place rest of the queens */
                if ( solveNQueensUtil(board, col + 1, slashCode, backslashCode,
                        rowLookup, slashCodeLookup, backslashCodeLookup) )
                    return true;

            /* If placing queen in board[i][col]
            doesn't lead to a solution, then backtrack */

                /* Remove queen from board[i][col] */
                board[i][col] = 0;
                rowLookup[i] = false;
                slashCodeLookup[slashCode[i][col]] = false;
                backslashCodeLookup[backslashCode[i][col]] = false;
            }
        }

    /* If queen can not be place in any row in
        this colum col then return false */
        return false;
    }


    boolean solveNQueens()
    {
       // System.out.println("N = "+N);
        int board[][] = new int[N][N];
        for(int i=0;i<N;i++)
        {
            for(int j=0;j<N;j++)
                board[i][j]=0;
        }

        // helper matrices
        int slashCode[][] = new int[N][N];
        int backslashCode[][] = new int[N][N];

        // arrays to tell us which rows are occupied
        boolean rowLookup[] = new boolean[N];
        for(int i=0;i<N;i++)
            rowLookup[i]=false;

        //keep two arrays to tell us which diagonals are occupied
        boolean slashCodeLookup[] = new boolean[2*N - 1];
        for(int i=0;i<2*N-1;i++)
            slashCodeLookup[i]=false;
        boolean backslashCodeLookup[] = new boolean[2*N - 1];
        for(int i=0;i<2*N-1;i++)
            backslashCodeLookup[i]=false;

        // initalize helper matrices
        for (int r = 0; r < N; r++) {
            for (int c = 0; c < N; c++) {
                slashCode[r][c] = r + c;
                backslashCode[r][c] = r - c + N-1;
            }
        }

        if (solveNQueensUtil(board, 0, slashCode, backslashCode,
                rowLookup, slashCodeLookup, backslashCodeLookup) == false )
        {
            System.out.println("solution does not exist");

            return false;
        }

        // solution found
        printSolution(board);
        
        return true;
    }

    void setN(int n)
    {
        this.N=n;
    }

    public static void main(String[] args) 
    {
        branch_and_bound q = new branch_and_bound();
        Scanner sc = new Scanner(System.in);
        System.out.println("Enter value of N");
        int N = sc.nextInt();
        q.setN(N);
        q.solveNQueens();

    }
}
