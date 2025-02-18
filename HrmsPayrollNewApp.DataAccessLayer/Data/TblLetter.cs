using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TblLetter
{
    public int LtId { get; set; }

    public int? LtLetterType { get; set; }

    public int? LtLetterFormat { get; set; }

    public string? LtDescription { get; set; }
}
