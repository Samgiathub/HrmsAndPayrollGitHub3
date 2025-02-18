using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0081EmpLetterRefDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string LetterName { get; set; } = null!;

    public string ReferenceNo { get; set; } = null!;

    public DateTime IssueDate { get; set; }
}
