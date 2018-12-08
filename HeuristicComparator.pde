public class HeuristicComparator implements Comparator<Point> {
    int size;
    HeuristicComparator(int size){
      this.size = size;
    }
    @Override
    public int compare(Point o1, Point o2) {
        if (dist(o2.x, o2.y, size/2, size/2) < dist(o1.x, o1.y, size/2, size/2)){
          return 1;
        } else if (dist(o2.x, o2.y, size/2, size/2) == dist(o1.x, o1.y, size/2, size/2)){
          return 0;
        }
        
        return -1;
    }
}