using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SapGesch
{
    public int GeschId { get; set; }

    public string? Gesch { get; set; }

    public string? Description { get; set; }

    public string? Alias { get; set; }
}
