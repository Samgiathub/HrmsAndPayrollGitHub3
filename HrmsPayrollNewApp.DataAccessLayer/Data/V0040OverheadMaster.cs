using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040OverheadMaster
{
    public int OverheadId { get; set; }

    public decimal? ProjectId { get; set; }

    public string? OverHeadMonth { get; set; }

    public decimal? OverHeadYear { get; set; }

    public decimal? ProjectCost { get; set; }

    public string? ProjectName { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? ExchangeRate { get; set; }
}
