using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040BandMaster
{
    public decimal BandId { get; set; }

    public string? Bandcode { get; set; }

    public string? BandName { get; set; }

    public decimal? SortingNo { get; set; }

    public bool? IsActive { get; set; }

    public int? CmpId { get; set; }

    public string? IsActiveEffDate { get; set; }
}
