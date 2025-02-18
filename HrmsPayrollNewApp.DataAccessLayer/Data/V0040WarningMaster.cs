using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040WarningMaster
{
    public decimal WarId { get; set; }

    public decimal CmpId { get; set; }

    public string? WarName { get; set; }

    public string? WarComments { get; set; }

    public decimal? DeductRate { get; set; }

    public string DeductType { get; set; } = null!;

    public decimal LevelId { get; set; }

    public string? LevelName { get; set; }

    public decimal? NoOfCard { get; set; }

    public string? CardColor { get; set; }
}
