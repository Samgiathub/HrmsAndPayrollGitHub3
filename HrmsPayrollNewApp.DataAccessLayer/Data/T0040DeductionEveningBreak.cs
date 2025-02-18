using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040DeductionEveningBreak
{
    public int TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? FromSlab { get; set; }

    public decimal? ToSlab { get; set; }

    public decimal? DeductionAmount { get; set; }

    public string? SinglePunch { get; set; }
}
