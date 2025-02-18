using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ExitAnalysisRating
{
    public decimal RatingId { get; set; }

    public decimal CmpId { get; set; }

    public string? Title { get; set; }

    public string? Description { get; set; }

    public decimal Rating { get; set; }
}
