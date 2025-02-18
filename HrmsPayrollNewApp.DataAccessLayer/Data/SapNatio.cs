using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SapNatio
{
    public int NatioId { get; set; }

    public string? Natio { get; set; }

    public string? Description { get; set; }

    public string? Alias { get; set; }
}
