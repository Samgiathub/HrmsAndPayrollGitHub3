using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SarNotMatchEnrollNo
{
    public DateTime ForDate { get; set; }

    public string EnrollNo { get; set; } = null!;

    public string FileName { get; set; } = null!;
}
