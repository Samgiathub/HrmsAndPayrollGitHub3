using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SapTitle
{
    public int TitleId { get; set; }

    public string? Title { get; set; }

    public string? Alias { get; set; }
}
