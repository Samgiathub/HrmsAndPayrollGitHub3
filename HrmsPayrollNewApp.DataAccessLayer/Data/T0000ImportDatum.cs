using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0000ImportDatum
{
    public decimal TranId { get; set; }

    public string Name { get; set; } = null!;

    public string RightName { get; set; } = null!;

    public decimal Value { get; set; }

    public string TabName { get; set; } = null!;

    public string? ModuleName { get; set; }

    public decimal? FormId { get; set; }

    public string? FormName { get; set; }
}
