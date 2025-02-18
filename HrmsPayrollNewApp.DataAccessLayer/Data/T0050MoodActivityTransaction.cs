using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050MoodActivityTransaction
{
    public int MoodActivityId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? Activity { get; set; }

    public string? MoodDetails { get; set; }

    public DateTime? SystemDate { get; set; }
}
