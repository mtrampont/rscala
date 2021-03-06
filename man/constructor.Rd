\name{constructor}
\alias{scalaInterpreter}
\alias{javaCmd}
\alias{scalaInfo}
\alias{scalaInstall}
\alias{rscalaJar}
\alias{rscalaPackage}
\alias{rscalaLoad}
\docType{methods}
\title{
Creates an instance of an embedded Scala compiler/interpreter.
Provides file paths for Java, Scala, and this package's JAR file.
Provides functions to enable other packages to depend on this package.
}
\description{
The function \code{\link{scalaInterpreter}} creates an instance of an embedded
Scala compiler/interpreter and binds a Scala object named \code{R} to permit
callbacks to \R.  Options are available to customize where Scala and Java are
found and how they are invoked (e.g., setting the classpath and maximum heap
size). Multiple interpreters can be created and each runs independently with
its own memory.  Each interpreter can use multiple threads/cores, but the
bridge between \R and Scala is not thread-safe.  As such, multiple \R
threads/cores should not simultaneously access the same interpreter. 

The functions \code{\link{javaCmd}}, \code{\link{scalaInfo}}, and
\code{\link{rscalaJar}} provide file paths to JAR files, installation
directories, and executables for Java, Scala, and this package.
\code{\link{scalaInstall}} downloads and installs Scala in \dQuote{~/.rscala}
in the user's home directory.  System administrators should install Scala
globally as described here:
\url{http://www.scala-lang.org/download/install.html}.  In short, simply
download the archive, unpack it, and add the \dQuote{scala} script to the path. 

The function \code{\link{rscalaPackage}} should only be called by the
\code{.onLoad} function of a package that wishes to depend on this
package.  The function creates an environment \code{E} in that package's
namespace which is available in any of that package's functions but
is not exported.  The \code{E$jars} variable is a character vector giving the
full path of all the JAR files in the \sQuote{java} directory of that package.
The \code{E$pkgname} variable gives that package's name.  Once the
\code{\link{rscalaLoad}} function is called (probably outside that packages's
\code{.onLoad} function), \code{E$s} is an instance of an embedded
Scala compiler/interpreter.  Like \code{\link{rscalaPackage}},
\code{\link{rscalaLoad}} should only be called by a package that wishes to
depend on this package.
}
\usage{
scalaInterpreter(classpath=character(0),
    scala.home=NULL, java.home=NULL, java.heap.maximum="256M", java.opts=NULL,
    timeout=60, debug.filename=NULL)
javaCmd(java.home=NULL, verbose=FALSE)
scalaInfo(scala.home=NULL, verbose=FALSE)
scalaInstall()
rscalaJar(version="")
rscalaPackage(pkgname)
rscalaLoad(classpath=NULL, ...)
}
\arguments{
    \item{classpath}{A character vector whose elements are paths to JAR files or directories which specify the classpath for the Scala compiler/interpreter.  If left equal to \code{NULL} in the function \code{\link{rscalaLoad}}, the package variable \code{E$jars} --- which is set by an earlier call to the function \code{\link{rscalaPackage}} --- is used.}
    \item{scala.home}{A character vector of length one giving the path where Scala is installed.  When set to \code{NULL} (the default), the function sequentially tries to find the Scala home by:  i. using the environment variable \code{SCALA_HOME}, ii. querying the operating system search path, and iii. looking in \code{~/.rscala/scala-X} where \code{X} is the recommended Scala version number (e.g. 2.11.5) for the package.  If all these fail, the function offers to download and install Scala in the above mentioned path (if the current \R session is interactive) or it downloads and installs Scala in a temporary directory (if the current \R session is noninteractive).}
    \item{java.home}{A character vector of length one giving the path where Java is installed.  When set to \code{NULL} (the default), the function sequentially tries to find the Java home by:  i. using the environment variable \code{JAVACMD}, ii. using the environment variable \code{JAVA_HOME}, and iii. querying the operating system search path.}
    \item{java.heap.maximum}{A character vector of length one used to specify the maximum heap size in the JVM.  The default is \sQuote{256M} which is equivalent to invoking Java with command line argument \sQuote{-Xmx256M}.  This option is ignored if \var{java.opts} is not null.}
    \item{java.opts}{A character vector whose elements are passed as command line arguments when invoking the JVM.  The default value is \code{NULL}, meaning no extra arguments are provided.}
    \item{timeout}{A numeric vector of length one giving the number of seconds to wait for Scala to start before aborting.  The default value is \code{60} seconds.}
    \item{debug.filename}{An option meant only for developers of the package itself and not intended for users of the package.}
    \item{verbose}{A logical vector of length one indicating whether information regarding the search for Scala and Java installation should be displayed.}
    \item{version}{If \code{""}, the package JAR files for all Scala versions are returned. Or, if \code{"2.10.*"} or \code{"2.11.*"} where \code{*} is a placeholder, the JAR file for that specific major version of Scala is returned.}
    \item{pkgname}{A character string giving the name of the package (as provided the second argument of the \code{.onLoad} function) that wishes to depend on this package.}
    \item{...}{These arguments are passed to the \code{\link{scalaInterpreter}} function.}
}
\value{
    \code{\link{scalaInterpreter}} returns an \R object representing an embedded Scala interpreter.

    \code{\link{javaCmd}} returns the path of the Java executable.

    \code{\link{scalaInfo}} returns a list detailing the Scala executable, version, jars, etc.
}
\author{
David B. Dahl \email{dahl@stat.byu.edu}
}
\seealso{
  \code{\link{intpEval}},
  \code{\link{intpSet}},
  \code{\link{intpGet}},
  \code{\link{intpDef}},
  \code{\link{intpSettings}},
  \code{\link{strintrplt}}
}
\keyword{interface}
\examples{
rscalaJar()
javaCmd()
scalaInfo(verbose=TRUE)

\dontrun{
# Uncomment the next line to download and install Scala
# scalaInstall()

# Make an instance of the Scala interpreter and see how it can print to the R console
s <- scalaInterpreter()
s \%~\% 'println("This is Scala "+scala.util.Properties.versionString)'

# Function defined in R
myMean <- function(x) {
  cat("Here I am.\n")
  mean(x)
}

# Function defined in Scala that calls an R function
callRFunction <- s$def('functionName: String, x: Array[Double]','
  R.xx = x
  R.eval("y <- "+functionName+"(xx)")
  R.y._1
')

# Have Scala call the R function myMean with input 1:100
callRFunction('myMean',1:100)
}
}

