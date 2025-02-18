using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GrievanceHeairngCalendar
{
    public int Id { get; set; }

    public string? Title { get; set; }

    public int IsMultipleDay { get; set; }

    public string Url { get; set; } = null!;

    public string? Description { get; set; }

    public string? Start { get; set; }

    public string? End { get; set; }

    public string BackgroundColor { get; set; } = null!;

    public string BorderColor { get; set; } = null!;

    public DateTime? Hdate { get; set; }

    public int? CmpId { get; set; }

    public int GAllocationId { get; set; }
}
