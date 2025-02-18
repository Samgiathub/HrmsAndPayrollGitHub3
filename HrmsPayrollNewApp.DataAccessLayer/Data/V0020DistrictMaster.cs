using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0020DistrictMaster
{
    public decimal DistId { get; set; }

    public string? DistName { get; set; }

    public decimal StateId { get; set; }

    public string StateName { get; set; } = null!;

    public string? LocName { get; set; }

    public decimal? LocId { get; set; }

    public decimal? CmpId { get; set; }
}
