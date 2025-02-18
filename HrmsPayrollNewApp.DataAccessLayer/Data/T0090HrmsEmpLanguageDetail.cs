using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsEmpLanguageDetail
{
    public int TranId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LangId { get; set; }

    public string IsRead { get; set; } = null!;

    public string IsWrite { get; set; } = null!;

    public string IsSpeak { get; set; } = null!;
}
