import processing.video.Movie;
import java.util.List;
import codeanticode.syphon.SyphonServer;
import java.util.Queue;
import java.io.FilenameFilter;
import java.util.LinkedList;
import java.util.Collections;

SyphonServer server;
Movie currentMovie;
Integer innerVideoLoopCount;
Integer innerVideoLoopTarget;

final static Integer TARGET_PLAYTIME = 45;

final static String FLAT_MOVIE_DIRECTORY_ROOT = "/Users/jdurbin/Movies/VJ Loops";

static final FilenameFilter VIDEO_FILTER = new FilenameFilter() {
  final String[] EXTS = {
    "mp4", "webm", "mov"
  };

  boolean accept(File f, String name) {
    name = name.toLowerCase();
    for (String s : EXTS)  if (name.endsWith(s))  return true;
    return false;
  }
};

final List<Movie> movie = populateMovies();
final Queue<Movie> queuedMovies = new LinkedList<Movie>();

void setup() {

  server = new SyphonServer(this, "Synesthesia Video Streamer");
  size(1280, 720, P2D);
  currentMovie = getNextMovie();
  currentMovie.play();
  currentMovie.volume(0);

  innerVideoLoopCount = 0;
  innerVideoLoopTarget = Math.round(TARGET_PLAYTIME / currentMovie.duration());
  currentMovie.play();
  currentMovie.volume(0);
}

Movie getNextMovie() {

  if (queuedMovies.isEmpty()) {
    Collections.shuffle(movie);
    queuedMovies.addAll(movie);
  }

  return queuedMovies.poll();
}

List<Movie> populateMovies() {

  final List<Movie> videos = new ArrayList<Movie>();
  final File movieDirectory = dataFile(FLAT_MOVIE_DIRECTORY_ROOT);

  for (String moviePath : movieDirectory.list(VIDEO_FILTER)) {
    videos.add(new Movie(this, FLAT_MOVIE_DIRECTORY_ROOT + "/" + moviePath));
  }

  return videos;
}

void draw(){

  image(currentMovie, 0, 0);
  set(width - currentMovie.width >> 1, height - currentMovie.height >> 1, currentMovie);
  server.sendScreen();

  if (currentMovie.duration() == currentMovie.time() && innerVideoLoopCount == innerVideoLoopTarget) {

    currentMovie.stop();
    currentMovie = getNextMovie();
    currentMovie.play();
    currentMovie.volume(0);

    innerVideoLoopCount = 0;
    innerVideoLoopTarget = Math.round(TARGET_PLAYTIME / currentMovie.duration());

  } else if (currentMovie.duration() == currentMovie.time() && innerVideoLoopCount < innerVideoLoopTarget) {

    innerVideoLoopCount++;

    currentMovie.stop();
    currentMovie.play();
    currentMovie.volume(0);
  }
}

void movieEvent(Movie m) {
  m.read();
}

void keyPressed() {

  if (key == 'n') {

    currentMovie.stop();
    currentMovie = getNextMovie();
    currentMovie.play();
    currentMovie.volume(0);
  } else if (key == 'e') {

    currentMovie.stop();
    queuedMovies.clear();
    currentMovie = getNextMovie();
    currentMovie.play();
    currentMovie.volume(0);
  }

}
