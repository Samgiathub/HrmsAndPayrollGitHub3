using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0020WeightageMaster
{
    public int CmpId { get; set; }

    public int WeightageId { get; set; }

    public string WeightageCode { get; set; } = null!;

    public string WeightageType { get; set; } = null!;

    public int IsActive { get; set; }

    public int UserId { get; set; }

    public DateTime CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }
}
