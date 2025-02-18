using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0010EmpGallery
{
    public decimal GalleryId { get; set; }

    public string? Type { get; set; }

    public string? Purpose { get; set; }

    public string? Name { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? UploadBy { get; set; }

    public DateTime? UploadDate { get; set; }

    public string? EmpIdMulti { get; set; }

    public string? EmpCodeMulti { get; set; }

    public string? GalleryName { get; set; }

    public DateTime ExpiryDate { get; set; }
}
