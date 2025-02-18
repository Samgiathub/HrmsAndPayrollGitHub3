using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class LeaveArFlagSap
{
    public int Id { get; set; }

    public decimal? LeaveAppId { get; set; }

    public string? Flag { get; set; }

    public DateTime? CreatedDate { get; set; }
}
