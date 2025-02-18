using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SapAnsvh
{
    public int AnsvhId { get; set; }

    public string? Ansvh { get; set; }

    public string? Description { get; set; }

    public string? Alias { get; set; }
}
