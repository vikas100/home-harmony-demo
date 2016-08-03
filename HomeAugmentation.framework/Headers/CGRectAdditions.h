#ifndef cgrect_additions_h
#define cgrect_additions_h

static inline CGRect
CGRectSetX(CGFloat x, CGRect rect)
{
    rect.origin.x = x;
    return rect;
}

static inline CGRect
CGRectSetY(CGFloat y, CGRect rect)
{
    rect.origin.y = y;
    return rect;
}

static inline CGRect
CGRectSetW(CGFloat w, CGRect rect)
{
    rect.size.width = w;
    return rect;
}

static inline CGRect
CGRectSetH(CGFloat h, CGRect rect)
{
    rect.size.height = h;
    return rect;
}

static inline CGRect
CGRectAddVals(CGFloat x, CGFloat y, CGFloat w, CGFloat h, CGRect rect)
{
    rect.origin.x += x;
    rect.origin.y += y;
    rect.size.width += w;
    rect.size.height += h;
    return rect;
}
static inline CGRect
CGRectAddX(CGFloat x, CGRect rect)
{
    rect.origin.x += x;
    return rect;
}
static inline CGRect
CGRectAddY(CGFloat y, CGRect rect)
{
    rect.origin.y += y;
    return rect;
}
static inline CGRect
CGRectAddW(CGFloat w, CGRect rect)
{
    rect.size.width += w;
    return rect;
}
static inline CGRect
CGRectAddH(CGFloat h, CGRect rect)
{
    rect.size.height += h;
    return rect;
}

static inline CGRect
CGRectCenterY(CGRect child, CGRect parent)
{
    child.origin.y = (int) ((parent.size.height / 2.0f) - (child.size.height / 2.0f));
    return child;
}

static inline CGRect
CGRectCenterX(CGRect child, CGRect parent)
{
    child.origin.x = (int) ((parent.size.width / 2.0f) - (child.size.width / 2.0f));
    return child;
}

static inline CGRect
CGRectCenter(CGRect child, CGRect parent)
{
    child = CGRectCenterX(child, parent);
    child = CGRectCenterY(child, parent);
    return child;
}

static inline CGRect
CGRectSetOrigin(CGPoint origin, CGRect rect)
{
    rect.origin = origin;
    return rect;
}

static inline CGRect
CGRectSetSize(CGSize size, CGRect rect)
{
    rect.size = size;
    return rect;
}

#endif