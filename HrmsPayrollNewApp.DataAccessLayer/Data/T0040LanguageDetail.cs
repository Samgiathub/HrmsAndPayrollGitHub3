using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040LanguageDetail
{
    public int LangId { get; set; }

    public decimal CmpId { get; set; }

    public string? English { get; set; }

    public string? Languages { get; set; }

    public string? Remark { get; set; }

    public bool Active { get; set; }

    public int? Sortid { get; set; }
}
