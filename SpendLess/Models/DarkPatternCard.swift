//
//  DarkPatternCard.swift
//  SpendLess
//
//  Dark pattern education card model
//

import Foundation

struct DarkPatternCard: Identifiable, Equatable {
    let id: UUID
    let sortOrder: Int
    let icon: String
    let name: String
    let tactic: String
    let explanation: String
    let reframe: String
    var learnedAt: Date?
    let cooldownDuration: Int // Days before resurfacing
    let category: String
    let subcategory: String?
    
    init(
        id: UUID = UUID(),
        sortOrder: Int,
        icon: String,
        name: String,
        tactic: String,
        explanation: String,
        reframe: String,
        learnedAt: Date? = nil,
        cooldownDuration: Int = 14,
        category: String,
        subcategory: String? = nil
    ) {
        self.id = id
        self.sortOrder = sortOrder
        self.icon = icon
        self.name = name
        self.tactic = tactic
        self.explanation = explanation
        self.reframe = reframe
        self.learnedAt = learnedAt
        self.cooldownDuration = cooldownDuration
        self.category = category
        self.subcategory = subcategory
    }
    
    // MARK: - Computed Properties
    
    var isLearned: Bool {
        learnedAt != nil
    }
    
    var isInCooldown: Bool {
        guard let learnedAt else { return false }
        let daysSinceLearned = Calendar.current.dateComponents([.day], from: learnedAt, to: Date()).day ?? 0
        return daysSinceLearned < cooldownDuration
    }
    
    var isAvailable: Bool {
        !isLearned || !isInCooldown
    }
    
    // MARK: - Equatable
    
    static func == (lhs: DarkPatternCard, rhs: DarkPatternCard) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Example Card Data

extension DarkPatternCard {
    /// Example card: Fake Urgency
    /// This demonstrates the full structure of a dark pattern education card
    static let fakeUrgency = DarkPatternCard(
        sortOrder: 1,
        icon: "⏰",
        name: "Fake Urgency",
        tactic: "\"Sale ends in 2 hours!\"",
        explanation: """
        Countdown timers trigger your brain's loss aversion instinct. We're wired to fear missing out more than we value gaining something.

        The reality? These timers often reset automatically. The same "24-hour sale" runs every week. If a deal is real, it'll still be there tomorrow.

        Retailers know that urgency bypasses your rational thinking. When you feel rushed, you don't have time to ask "Do I actually need this?"
        """,
        reframe: "Would I want this if there was no timer?",
        category: "dark-patterns"
    )

    
    
    /// Dopamine Menu Framework
    static let dopamineMenu = DarkPatternCard(
        sortOrder: 2,
        icon: "📋",
        name: "Dopamine Menu",
        tactic: "\"I'll just browse for a minute...\"",
        explanation: """
        Shopping gives you a quick dopamine hit, but it's not the only way to feel good. The Dopamine Menu is a pre-made list of non-shopping activities that give you that same satisfying feeling.

        When you feel the urge to shop, you must try at least one thing from your menu first. This creates a pause between the impulse and the action, giving your rational brain time to catch up.

        The key is having your menu ready before you need it. Write it down, keep it accessible. When the shopping urge hits, you're not trying to think of alternatives—you're choosing from options you've already curated.
        """,
        reframe: "What's on my dopamine menu today? (Walk with a podcast, bake something, play music, dance, snuggle a pet, sit in the sun...)",
        category: "behavioral-psychology"
    )
    
    /// Frictionless vs Effortful Dopamine
    static let frictionlessDopamine = DarkPatternCard(
        sortOrder: 3,
        icon: "⚡",
        name: "Frictionless vs Effortful Dopamine",
        tactic: "\"One-click purchase\"",
        explanation: """
        Dopamine is the "do it again" chemical, not happiness. There's a crucial difference between frictionless dopamine (one-click shopping, endless scrolling) and effortful dopamine (activities that require work).

        Frictionless dopamine is like a potato chip—easy, addictive, but ultimately unsatisfying. Effortful dopamine is like a loaded baked potato—it takes more work, but it's deeply satisfying and doesn't leave you wanting more.

        Retailers remove all friction to make shopping effortless. But you can add friction back: force yourself to drive to the store, try it on, pay cash. By the time you've done all that, the desire often passes. The effort itself becomes the filter.
        """,
        reframe: "Can I add friction to this purchase? Or choose an effortful dopamine activity instead?",
        category: "behavioral-psychology"
    )



    // MARK: - Dark Patterns
    
    /// The Fake Scarcity Trap
    static let fakeScarcityTrap = DarkPatternCard(
        sortOrder: 1,
        icon: "🎭",
        name: "The Fake Scarcity Trap",
        tactic: "\"Only 3 left in stock!\"",
        explanation: """
        E-commerce sites trick you into thinking products are limited when they're sitting on mountains of inventory. That 'Only 3 left!' message? Often completely fabricated to make you act before you think.
        Just as frequently, they'll show items as 'out of stock' to get you on a waitlist—handing over your email for more promotions. When the item 'returns,' they hit you with the same urgency tactics.
        The goal is always the same: bypass your rational brain and trigger an impulse response. Real scarcity doesn't need a flashing banner.
        """,
        reframe: "If this were truly scarce, would they need to tell me? What happens if I miss it?",
        category: "dark-patterns"
    )

    /// Countdown Timers That Lie
    static let countdownTimers = DarkPatternCard(
        sortOrder: 2,
        icon: "⏱️",
        name: "Countdown Timers That Lie",
        tactic: "\"Sale ends in 2:34:17!\"",
        explanation: """
        Princeton researchers found that countdown timers often reset automatically or deals stay valid long after 'expiration.' These timers exist for one reason: to short-circuit your decision-making and trigger panic buying.
        The ticking clock creates artificial urgency. Your brain shifts from 'Do I need this?' to 'Can I get it in time?' That's exactly what they want.
        Next time you see a countdown, try refreshing the page or coming back tomorrow. You'll often find the 'expired' deal is miraculously still available.
        """,
        reframe: "What if I refresh this page? Will the timer reset? What if I come back tomorrow?",
        category: "dark-patterns"
    )

    /// Social Proof Manipulation
    static let socialProofManipulation = DarkPatternCard(
        sortOrder: 3,
        icon: "👥",
        name: "Social Proof Manipulation",
        tactic: "\"47 people are viewing this right now\"",
        explanation: """
        That '47 people viewing this' notification? It's designed to make you feel like you're in a race. Combined with countdown timers and low-stock warnings, it tricks your brain into thinking hesitation means losing to strangers.
        The anxiety you feel isn't random—it's engineered. These numbers are often inflated, fabricated, or counting bots. Even when real, they're irrelevant to whether you actually need the item.
        Competition triggers our survival instincts. Retailers hijack this ancient wiring to sell you things you don't need.
        """,
        reframe: "Am I buying this because I want it, or because I'm afraid someone else will get it?",
        category: "dark-patterns"
    )

    /// Confirmshaming Psychology
    static let confirmshaming = DarkPatternCard(
        sortOrder: 4,
        icon: "😔",
        name: "Confirmshaming Psychology",
        tactic: "\"No thanks, I hate saving money\"",
        explanation: """
        Confirmshaming uses guilt to manipulate your choices. When you try to unsubscribe or skip a sale, you'll see options like 'No thanks, I hate saving money' or 'I don't want to look my best.'
        It's designed to make you feel stupid for saying no—so you say yes against your better judgment. The language frames your rational decision as irrational, your self-control as self-sabotage.
        Remember: a company that respects you doesn't need to shame you into buying. The guilt trip is a red flag, not a reason to comply.
        """,
        reframe: "Would I let a friend talk to me this way? Why am I letting a website do it?",
        category: "dark-patterns"
    )

/// The Anchoring Trap
    static let anchoringTrap = DarkPatternCard(
        sortOrder: 5,
        icon: "⚓",
        name: "The Anchoring Trap",
        tactic: "\"Was $200, now just $79!\"",
        explanation: """
        The anchoring trap tricks you into believing you're getting a deal, even when one never existed. You'll see inflated prices slashed dramatically—a digital course 'originally' $200, suddenly available for $79.
        In reality, the seller was always thrilled to get $79. The higher price never existed except to make the 'discount' feel irresistible. Your brain latches onto the first number it sees (the anchor) and judges everything relative to it.
        The question isn't 'How much am I saving?' It's 'Is this worth $79 to me right now?'
        """,
        reframe: "Ignore the original price. Is this item worth the actual price to me today?",
        category: "dark-patterns"
    )

/// One-Click Is No Accident
    static let oneClickNoAccident = DarkPatternCard(
        sortOrder: 6,
        icon: "☝️",
        name: "One-Click Is No Accident",
        tactic: "\"Buy now with 1-Click®\"",
        explanation: """
        Amazon patented one-click buying in 1999 for a reason: every extra step gives you time to reconsider. Friction is your friend. When sites remove it, they're removing your opportunity to ask 'Do I actually need this?'
        The faster they get you through checkout, the less time you have to think. Saved payment info, autofilled addresses, instant purchase buttons—all designed to collapse the gap between impulse and action.
        You can fight back by adding friction: delete saved cards, require passwords, use browser extensions that force a waiting period.
        """,
        reframe: "What friction can I add back? Can I make this purchase harder on purpose?",
        category: "dark-patterns"
    )

/// Your Cart Misses You
    static let cartMissesYou = DarkPatternCard(
        sortOrder: 7,
        icon: "🛒",
        name: "Your Cart Misses You",
        tactic: "\"You left something behind!\"",
        explanation: """
        Those 'You left something behind!' emails have 50% higher open rates than regular marketing. That's why sites push you to log in while browsing—so they can follow up with personalized guilt trips, often sweetened with 'limited time' discounts.
        Your abandoned cart is their open opportunity. They'll email you, show you retargeted ads, and create a sense of unfinished business that nags at your brain.
        The best defense? Browse logged out, or regularly clear your cart. An empty cart can't miss you.
        """,
        reframe: "I abandoned that cart on purpose. My past self was protecting my future self.",
        category: "dark-patterns"
    )

/// How Shein Hooks You
    static let sheinHooks = DarkPatternCard(
        sortOrder: 8,
        icon: "🪝",
        name: "How Shein Hooks You",
        tactic: "\"New styles added every day!\"",
        explanation: """
        Fast fashion giant Shein deploys 18 of 20 known dark patterns—and they're likely inventing new ones. Infinite scroll, gamified discounts, flash sales, points systems, push notifications: it's a masterclass in manipulation.
        If you ever feel pulled back to your cart by invisible forces, that's not weakness. That's a billion-dollar manipulation machine doing exactly what it was designed to do.
        The more patterns stacked together, the harder they are to resist. Awareness is your first line of defense.
        """,
        reframe: "How many dark patterns can I spot on this page? What are they trying to make me feel?",
        category: "dark-patterns"
    )

// MARK: - Psychological Mechanisms

/// Your Brain on Shopping
    static let brainOnShopping = DarkPatternCard(
        sortOrder: 1,
        icon: "🧠",
        name: "Your Brain on Shopping",
        tactic: "\"I just get such a rush when I buy things\"",
        explanation: """
        Impulsive shopping isn't a character flaw—it's brain chemistry. MRI studies show shopping activates the same dopamine pathways as gambling and substance use.
        The rush you feel browsing for deals? It's the same neurological response that makes those activities addictive. Your brain literally can't tell the difference between finding a 'great deal' and winning at slots.
        Understanding this isn't an excuse; it's the first step to building better defenses. You're not fighting a moral failing—you're managing a neurological response.
        """,
        reframe: "This rush is just dopamine. It will pass. What do I actually need?",
        category: "psychological-mechanisms"
    )

/// The Anticipation High
    static let anticipationHigh = DarkPatternCard(
        sortOrder: 2,
        icon: "✨",
        name: "The Anticipation High",
        tactic: "\"I can't stop thinking about that jacket\"",
        explanation: """
        The biggest dopamine hit doesn't come when your package arrives—it comes while you're hunting for the 'perfect' item. Anticipation is the drug; the purchase is just the delivery mechanism.
        Retailers know this, which is why they layer on countdown timers and 'low stock' warnings during your browsing high. They're amplifying the anticipation to keep you hooked.
        Notice how the excitement fades once you've bought something? That's because the chase was the real reward. The item itself is almost beside the point.
        """,
        reframe: "Am I chasing this feeling or do I actually want the item? How will I feel in a week?",
        category: "psychological-mechanisms"
    )

/// The Hedonic Treadmill
    static let hedonicTreadmill = DarkPatternCard(
        sortOrder: 3,
        icon: "🏃",
        name: "The Hedonic Treadmill",
        tactic: "\"I need to do a bigger haul this time\"",
        explanation: """
        Each purchase delivers less satisfaction than the last, so you buy more to chase the same feeling. It's called the hedonic treadmill—you're running faster but staying in the same place emotionally.
        That's why shopping sprees keep getting bigger but never feel like enough. Your baseline resets after each high, requiring more stimulation next time.
        The only way off the treadmill is to stop running. Smaller, intentional purchases break the cycle better than bigger hauls ever could.
        """,
        reframe: "Will buying more actually make me happier, or am I just chasing a feeling that keeps moving?",
        category: "psychological-mechanisms"
    )

/// Stress Shopping & Cortisol
    static let stressShopping = DarkPatternCard(
        sortOrder: 4,
        icon: "😤",
        name: "Stress Shopping & Cortisol",
        tactic: "\"I had a rough day, I deserve this\"",
        explanation: """
        Shopping gives you a quick dopamine hit that temporarily masks stress—hence 'retail therapy.' But the relief fades fast, often replaced by buyer's remorse and financial anxiety.
        You're not solving stress; you're borrowing calm from your future self and charging interest. The credit card bill creates more stress than the purchase ever relieved.
        Next time you're stressed, try a walk, a call with a friend, or anything that doesn't cost money. Address the stress, not the symptom.
        """,
        reframe: "What am I actually stressed about? Will this purchase fix it or just delay it?",
        category: "psychological-mechanisms"
    )

/// The Boredom Buy
    static let boredomBuy = DarkPatternCard(
        sortOrder: 5,
        icon: "😑",
        name: "The Boredom Buy",
        tactic: "\"I'm just browsing to kill time\"",
        explanation: """
        Boredom is the #1 shopping trigger in recovery communities. When your brain is understimulated, it seeks novelty—and nothing delivers novelty like browsing new products.
        But shopping doesn't cure boredom; it distracts from it temporarily while creating new problems. The packages arrive, the novelty fades, and you're bored again—just with less money.
        The fix? Recognize boredom for what it is and redirect to something that actually satisfies without emptying your wallet.
        """,
        reframe: "Am I bored or am I shopping? What could I do right now that's free and engaging?",
        category: "psychological-mechanisms"
    )

/// The "I Deserve This" Trap
    static let iDeserveThisTrap = DarkPatternCard(
        sortOrder: 6,
        icon: "🏆",
        name: "The \"I Deserve This\" Trap",
        tactic: "\"I worked hard, I've earned it\"",
        explanation: """
        After a hard day or a big win, 'I deserve this' feels like self-care. But 80% of compulsive shoppers report buying to improve their mood.
        The problem? The mood boost is temporary, but the credit card bill is permanent. You're rewarding yourself with a future problem.
        You do deserve good things—including financial peace, a clutter-free home, and freedom from buyer's remorse. Those rewards just don't come in packages.
        """,
        reframe: "I do deserve something. Do I deserve this specific item, or do I deserve peace of mind?",
        category: "psychological-mechanisms"
    )

/// Keeping Up With the Feed
    static let keepingUpWithFeed = DarkPatternCard(
        sortOrder: 7,
        icon: "📱",
        name: "Keeping Up With the Feed",
        tactic: "\"Everyone has this except me\"",
        explanation: """
        48% of millennials admit spending money they don't have to keep up with peers. Social media turns this into overdrive—you're not just comparing yourself to friends, but to curated highlight reels from thousands of strangers.
        Their 'hauls' aren't your reality, and their debt isn't visible in the photos. You're comparing your behind-the-scenes to everyone else's highlight reel.
        The feed never stops, which means 'keeping up' is impossible by design. The only winning move is to stop playing.
        """,
        reframe: "Am I buying this for me, or for how it looks to others? What would I want if no one could see?",
        category: "psychological-mechanisms"
    )

// MARK: - Behavioral Psychology

/// The Zeigarnik Effect
    static let zeigarnikEffect = DarkPatternCard(
        sortOrder: 1,
        icon: "🔄",
        name: "The Zeigarnik Effect",
        tactic: "\"I keep thinking about that item in my cart\"",
        explanation: """
        Your brain obsesses over unfinished tasks—psychologists call it the Zeigarnik Effect. Incomplete tasks occupy mental real estate until they're resolved.
        Retailers exploit this by keeping items in your cart, on your wishlist, or on a waitlist. That nagging feeling to 'complete' the purchase? It's manufactured incompleteness.
        Clear your carts and wishlists regularly. The task isn't to buy—it's to decide. Removing the item completes the loop just as well as purchasing it.
        """,
        reframe: "The task isn't 'buy this.' The task is 'decide.' I can complete it by removing the item.",
        category: "behavioral-psychology"
    )

/// The Ovsiankina Effect
    static let ovsiankinaEffect = DarkPatternCard(
        sortOrder: 2,
        icon: "⏸️",
        name: "The Ovsiankina Effect",
        tactic: "\"I got distracted mid-checkout, I should go finish\"",
        explanation: """
        Related to the Zeigarnik Effect, the Ovsiankina Effect describes our urge to resume interrupted tasks. Your brain treats interruption as a problem to solve, not a chance to reconsider.
        Ever get distracted mid-checkout, then feel compelled to go back and finish? That's not you being responsible—it's your brain being hijacked by an incomplete loop.
        The interruption was a gift. Your past self created an exit ramp. Take it.
        """,
        reframe: "Getting interrupted was a sign. Do I still want this, or do I just want to 'finish'?",
        category: "behavioral-psychology"
    )

/// The Endowment Effect
    static let endowmentEffect = DarkPatternCard(
        sortOrder: 3,
        icon: "🤲",
        name: "The Endowment Effect",
        tactic: "\"But I already put it in my cart\"",
        explanation: """
        Once you own something—or even just put it in your cart—you value it 2-3x more than before. Psychological ownership kicks in before you've paid a cent.
        This is why 'try before you buy,' virtual try-ons, and 'hold this item' features are so effective. The moment you picture yourself with it, letting go feels like loss.
        Retailers count on this. Your cart isn't a holding area—it's a commitment device designed to make you feel like you already own those items.
        """,
        reframe: "I don't own this yet. Removing it from my cart isn't losing something—it's keeping my money.",
        category: "behavioral-psychology"
    )

/// The IKEA Effect
    static let ikeaEffect = DarkPatternCard(
        sortOrder: 4,
        icon: "🔧",
        name: "The IKEA Effect",
        tactic: "\"I customized it myself, so it's special\"",
        explanation: """
        We overvalue things we helped create—even if that 'help' is just assembling furniture or customizing colors. Labor creates love, even when the labor is trivial.
        Retailers use this by letting you 'build your bundle,' personalize products, or configure options. That emotional investment makes you willing to pay more and less likely to return it.
        The customization isn't about giving you what you want—it's about making you feel invested before you've spent anything.
        """,
        reframe: "Am I paying for the product or for the time I spent customizing it?",
        category: "behavioral-psychology"
    )

/// The Diderot Effect
    static let diderotEffect = DarkPatternCard(
        sortOrder: 5,
        icon: "🎁",
        name: "The Diderot Effect",
        tactic: "\"Now I need matching accessories\"",
        explanation: """
        One purchase often triggers a cascade of 'matching' purchases. A new scarf demands new gloves. A kitchen gadget needs accessories. One upgrade makes everything else look outdated.
        Philosopher Denis Diderot noticed this after receiving a fancy robe—he ended up replacing everything in his study to match it. One 'yes' became a complete lifestyle overhaul.
        Before buying, ask: what else will this 'require'? The true cost includes all the matching items you'll suddenly need.
        """,
        reframe: "If I buy this, what else will I 'need' to match it? What's the true total cost?",
        category: "behavioral-psychology"
    )

/// The Decoy Effect
    static let decoyEffect = DarkPatternCard(
        sortOrder: 6,
        icon: "🎯",
        name: "The Decoy Effect",
        tactic: "\"The large is basically the same price as the medium\"",
        explanation: """
        Ever notice a weird middle option that nobody would choose? That's the decoy. A small popcorn for $4, a medium for $7, and a large for $7.50 makes the large look like an obvious deal.
        The decoy exists only to push you toward what they wanted you to buy all along. It's not a real option—it's a manipulation tool disguised as a choice.
        The 'obvious' choice was designed, not discovered. Question why one option seems so clearly better.
        """,
        reframe: "Why does one option seem obviously better? Is there a decoy making me spend more?",
        category: "behavioral-psychology"
    )

/// The Paradox of Choice
    static let paradoxOfChoice = DarkPatternCard(
        sortOrder: 7,
        icon: "🤯",
        name: "The Paradox of Choice",
        tactic: "\"I've been researching for hours and still can't decide\"",
        explanation: """
        More options should mean better decisions, right? Wrong. In a famous study, shoppers shown 6 jam varieties bought at 10x the rate of those shown 24.
        Too many choices overwhelm us—and overwhelmed shoppers either freeze or grab something impulsively just to escape the decision fatigue. Either way, you lose.
        Limit your options intentionally. Pick one store, one brand, one price range. Constraints liberate you from endless comparison.
        """,
        reframe: "Am I still deciding, or am I just overwhelmed? Can I limit my options on purpose?",
        category: "behavioral-psychology"
    )

/// The Peak-End Rule
    static let peakEndRule = DarkPatternCard(
        sortOrder: 8,
        icon: "📈",
        name: "The Peak-End Rule",
        tactic: "\"Shopping was so fun last time\"",
        explanation: """
        We remember experiences by their best moment and their ending—not the average. That rush of finding the perfect item on sale? It overwrites the hours of anxiety, the money spent, the buyer's remorse.
        Retailers design for peaks: the thrill of discovery, the satisfaction of checkout, the anticipation of delivery. You forget the regret because it came in the middle.
        Your memory is being edited. Try writing down how you feel after purchases to create a more accurate record.
        """,
        reframe: "Am I remembering the whole experience, or just the peak? How did I really feel after?",
        category: "behavioral-psychology"
    )

// MARK: - Digital Wellness

/// TikTok Made Me Buy It
    static let tiktokMadeMeBuyIt = DarkPatternCard(
        sortOrder: 1,
        icon: "🎵",
        name: "TikTok Made Me Buy It",
        tactic: "\"Everyone on TikTok is obsessed with this\"",
        explanation: """
        67% of TikTok users report buying products they weren't planning to buy. The platform isn't just entertainment—it's a frictionless shopping funnel disguised as a social app.
        When everyone you follow is 'obsessed' with something, your brain stops asking if you need it. The algorithm shows you what sells, not what's best for you.
        That viral product wasn't discovered—it was promoted. Often by paid influencers who get it free or earn commission on every sale.
        """,
        reframe: "Did I want this before I saw it on TikTok? Is this organic or is it an ad?",
        category: "digital-wellness"
    )

/// FOMO Is Manufactured
    static let fomoManufactured = DarkPatternCard(
        sortOrder: 2,
        icon: "😰",
        name: "FOMO Is Manufactured",
        tactic: "\"I'll miss out if I don't buy now\"",
        explanation: """
        FOMO isn't a personal failing—it's an engineered response. 60% of shoppers admit to FOMO-driven purchases, and countdown timers boost conversion rates by 147%.
        That panic you feel when a 'deal' is ending? A designer put it there on purpose. Fear of missing out is manufactured by combining urgency, scarcity, and social proof.
        Real opportunities don't need to manufacture panic. If you feel rushed, that's a red flag, not a reason to buy faster.
        """,
        reframe: "Is this real urgency or manufactured FOMO? What's the worst that happens if I miss it?",
        category: "digital-wellness"
    )

/// The 23-Minute Cost
    static let twentyThreeMinuteCost = DarkPatternCard(
        sortOrder: 3,
        icon: "🔔",
        name: "The 23-Minute Cost",
        tactic: "\"I just got a notification about a flash sale\"",
        explanation: """
        It takes 23 minutes to regain full focus after an interruption. That push notification about a flash sale isn't just annoying—it's a calculated attempt to break your concentration and redirect your attention toward spending.
        Every ping is an invitation to impulse buy. Retailers know that catching you off-guard makes you more likely to purchase without thinking.
        Turn off shopping notifications entirely. If a sale is worth it, it'll still be there when you intentionally check.
        """,
        reframe: "Is this notification helping me or hijacking my focus? What was I doing before this?",
        category: "digital-wellness"
    )

// MARK: - ADHD Specific

/// ADHD and Dopamine Deficit
    static let adhdDopamineDeficit = DarkPatternCard(
        sortOrder: 1,
        icon: "⚡",
        name: "ADHD and Dopamine Deficit",
        tactic: "\"I just can't resist a good deal\"",
        explanation: """
        ADHD brains have lower baseline dopamine, making the instant reward of shopping especially appealing. People with ADHD are 4x more likely to impulse shop.
        This isn't about willpower—it's neurochemistry. Your brain is hungrier for dopamine hits, and shopping delivers them fast and reliably.
        Knowing this helps you build systems instead of relying on self-control alone. External guardrails work better than internal resistance when your brain is wired this way.
        """,
        reframe: "This is my brain seeking dopamine, not a real need. What system can protect me from myself?",
        category: "adhd-specific"
    )

/// The Hyperfocus Rabbit Hole
    static let hyperfocusRabbitHole = DarkPatternCard(
        sortOrder: 2,
        icon: "🕳️",
        name: "The Hyperfocus Rabbit Hole",
        tactic: "\"I researched for 4 hours, so I should definitely buy it\"",
        explanation: """
        ADHD hyperfocus can turn a quick product search into a 3AM deep dive: 73 reviews read, 47 websites compared, 23 browser tabs open.
        The irony? All that research doesn't prevent impulse buying—it just makes you feel more justified when you finally click 'purchase.' The time invested becomes a sunk cost pushing you toward buying.
        Set a timer before you start researching. When it goes off, step away—even if you haven't decided. Especially if you haven't decided.
        """,
        reframe: "Is my research helping me decide, or am I hyperfocusing? Would a timer help me stop?",
        category: "adhd-specific"
    )

// MARK: - Recovery

/// The HALT Check
    static let haltCheck = DarkPatternCard(
        sortOrder: 1,
        icon: "🛑",
        name: "The HALT Check",
        tactic: "\"I really need this right now\"",
        explanation: """
        Before any purchase, run the HALT check: Am I Hungry? Angry? Lonely? Tired? These states tank your decision-making and send you hunting for dopamine.
        When you're in a HALT state, your brain is compromised. It's not the right time to make spending decisions. Any urgency you feel is amplified by your state, not the situation.
        If any answer is 'yes,' address that need first—then see if you still want to buy. Most of the time, you won't.
        """,
        reframe: "HALT: Am I Hungry, Angry, Lonely, or Tired? Let me fix that first, then decide.",
        category: "recovery"
    )

/// Urge Surfing
    static let urgeSurfing = DarkPatternCard(
        sortOrder: 2,
        icon: "🌊",
        name: "Urge Surfing",
        tactic: "\"I can't stop thinking about buying this\"",
        explanation: """
        Shopping urges feel overwhelming, but they follow a predictable pattern: rise, peak, fade. Most subside within 20-30 minutes if you don't act on them.
        'Urge surfing' means observing the craving without fighting it—ride the wave and it will pass. Resistance often intensifies urges; observation lets them dissolve naturally.
        Set a timer for 30 minutes. Notice the urge, acknowledge it, but don't act. Watch what happens. The wave always breaks.
        """,
        reframe: "This urge will peak and pass. Can I watch it without acting for 30 minutes?",
        category: "recovery"
    )
    
    // MARK: - All Cards
    
    static let allCards: [DarkPatternCard] = [
        // Original example cards
        fakeUrgency,
        dopamineMenu,
        frictionlessDopamine,
        
        // Dark Patterns
        fakeScarcityTrap,
        countdownTimers,
        socialProofManipulation,
        confirmshaming,
        anchoringTrap,
        oneClickNoAccident,
        cartMissesYou,
        sheinHooks,
        
        // Psychological Mechanisms
        brainOnShopping,
        anticipationHigh,
        hedonicTreadmill,
        stressShopping,
        boredomBuy,
        iDeserveThisTrap,
        keepingUpWithFeed,
        
        // Behavioral Psychology
        zeigarnikEffect,
        ovsiankinaEffect,
        endowmentEffect,
        ikeaEffect,
        diderotEffect,
        decoyEffect,
        paradoxOfChoice,
        peakEndRule,
        
        // Digital Wellness
        tiktokMadeMeBuyIt,
        fomoManufactured,
        twentyThreeMinuteCost,
        
        // ADHD Specific
        adhdDopamineDeficit,
        hyperfocusRabbitHole,
        
        // Recovery
        haltCheck,
        urgeSurfing
    ]
}

