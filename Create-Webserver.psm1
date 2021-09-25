class Base_Ation{

    $received = $null
    $recode   = 200
    $reheader = @{}
    $rehtml   = ''
    $rebuffer = $null

    [String] Ation( $request ){
        $this.received = $request
        switch( $request.httpMethod ){
            "GET" {
                $this.rehtml = $this.get( $request ) ;
                break ; 
            }
            "POST" {
                $this.rehtml = $this.post( $request ) ;
                break ;
            }
            "HEAD" {
                $this.rehtml = $this.head( $request ) ;
                break ;
            }
            default {
                $this.recode = 501 ;
                break ;
            }
        }
        $this.rebuffer = [Text.Encoding]::UTF8.GetBytes( $this.rehtml ) ;
        return $this.rehtml ;
    }

    [void] Headers( $response ){
        $response.StatusCode = $this.recode

        $response.AddHeader("Last-Modified", [DATETIME]::Now.ToString('r')) ;
        $response.AddHeader("Server", "Powershell Webserver/1.2 on ") ;
    }

    [void] Send( $response ){
        $response.OutputStream.Write($this.rebuffer, 0, $this.rebuffer.Length) ;
        $response.Close() ;
    }

    [String] get( $received ){
        $path = $received.Url.LocalPath -replace "/" ,"\";
        $now  = (Get-Location).toString()
        $file = "$($now)$($path)"

        if(Test-Path $file){
            if((Get-Item $file) -is [IO.fileinfo]){
                return (python py.py)
                
                return Get-Content $file
            }

            else{
                $this.recode = 403 ;
                return 'is Directory' ;
            }
        }

        else{
            $this.recode = 404 ;
            return '404';
        }
    }

    [String] post( $received ){
        return 'post';
    }

    [String] head( $received ){
        return '';
    }

}


class Base_Server{
    $listener = $NULL ;
    $porting  = 8000  ; 
    $location = $NULL ;

    [void] Init_Server(){
        $this.location = "http://localhost:$($this.porting)/" ;
        $this.listener = New-Object System.Net.HttpListener ;

        $this.listener.Prefixes.Add($this.location) ;
    }

    [void] Start_Server(){
        $this.listener.Start() ;
        while ( $this.listener.IsListening ) {

            $handle = [Base_Ation]::new() ;

            $context  = $this.listener.GetContext() ;
            $request  = $context.Request ;
            $response = $context.Response;

            $handle.Ation( $request ) ;

            $response.ContentLength64 = $handle.rebuffer.Length ;

            $handle.Headers( $response )
            $handle.Send( $response )
        }
    }
}

function New_Server(){
    return [Base_Server]::new()
}