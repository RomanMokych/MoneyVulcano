//
//  GoalViewController.swift
//  MoneyVulcano
//
//  Created by Roman Mokych on 10/3/19.
//  Copyright © 2019 Roman Inc. All rights reserved.
//

import UIKit

protocol GoalObserver
{
    func onGoalUpdated(_ goal: Goal)
}

class Goal
{
    public func currentAmount() -> Int
    {
        return _currentAmount
    }
    
    public func setCurrentAmount(_ currentAmount: Int)
    {
        _currentAmount = currentAmount
    }
    
    public func goalAmount() -> Int
    {
        return _goalAmount
    }
    
    public func setGoalAmount(_ goalAmount: Int)
    {
        _goalAmount = goalAmount
        _observer?.onGoalUpdated(self)
    }
    
    public func addMoney(_ amount: Int)
    {
        _currentAmount += amount
        _observer?.onGoalUpdated(self)
    }
    
    public func setObserver(_ observer: GoalObserver)
    {
        _observer = observer
    }
    
    private var _currentAmount = 0
    private var _goalAmount = 0
    
    private var _observer: GoalObserver?
}

class GoalObserverToStoreAdapter: GoalObserver
{
    public func onGoalUpdated(_ goal: Goal)
    {
        GoalStore().saveGoal(goal)
    }
}

class GoalStore
{
    public func saveGoal(_ goal: Goal)
    {
        let userDefaults = UserDefaults()
        
        userDefaults.set(goal.goalAmount(), forKey: "goal.amount")
        userDefaults.set(goal.currentAmount(), forKey: "goal.currentAmount")
    }
    
    public func loadGoal(_ goal: Goal)
    {
        let userDefaults = UserDefaults()
        
        goal.setGoalAmount(userDefaults.integer(forKey: "goal.amount"))
        goal.setCurrentAmount(userDefaults.integer(forKey: "goal.currentAmount"))
    }
}

class GoalViewController: UIViewController {

    @IBOutlet weak var currentMoneyAmountLabel: UILabel!
    @IBOutlet weak var goalMoneyAmountLabel: UILabel!
    @IBOutlet weak var inputTextView: UITextField!
    @IBOutlet weak var goalProgressSlider: UISlider!
    @IBOutlet weak var _goalAmountTextView: UITextField!
    
    let _goal = Goal()
    let _goalStore = GoalStore()
    let _observerToStoreAdapter = GoalObserverToStoreAdapter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        _goalStore.loadGoal(_goal)
        
        _goal.setObserver(_observerToStoreAdapter)

        currentMoneyAmountLabel.text = String(_goal.currentAmount())
        goalMoneyAmountLabel.text = String(_goal.goalAmount())
        
        goalProgressSlider.maximumValue = Float(_goal.goalAmount())
        goalProgressSlider.value = Float(_goal.currentAmount())
    }
    
    
    @IBAction func onPayedTap(_ sender: Any)
    {
        _goal.addMoney(input())
        
        currentMoneyAmountLabel.text = String(_goal.currentAmount())
        inputTextView.text = ""
        
        UIView.animate(withDuration: 1)
        {
            self.goalProgressSlider.setValue(Float(self._goal.currentAmount()), animated: true)
        }
    }
    
    @IBAction func onGoalValueChanged(_ sender: Any)
    {
        _goal.setGoalAmount(goalValue())
        
        goalMoneyAmountLabel.text = String(_goal.goalAmount())
        goalProgressSlider.maximumValue = Float(_goal.goalAmount())
        
        _goalAmountTextView.text = ""
        _goalAmountTextView.resignFirstResponder()
    }
    
    private func input() -> Int
    {
        return Int(inputTextView.text ?? "") ?? 0
    }
    
    private func goalValue() -> Int
    {
        return Int(_goalAmountTextView.text ?? "") ?? 0
    }
}

