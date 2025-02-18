using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0020TehsilMaster
{
    public decimal TId { get; set; }

    public string? TName { get; set; }

    public decimal StateId { get; set; }

    public string StateName { get; set; } = null!;

    public string? LocName { get; set; }

    public decimal? LocId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal DistId { get; set; }

    public string? DistName { get; set; }
}
